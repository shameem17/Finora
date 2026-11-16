//
//  LoanModels.swift
//  Finora
//
//  Screens/Loan/Model
//

import Foundation

// MARK: - Kind

/// `lent`     – you gave money to someone (they owe you). Shown as "Loan".
/// `borrowed` – you took money from someone / an institution (you owe them). Shown as "Borrow".
enum LoanKind: String, PickerOption {
    case lent = "Loan"
    case borrowed = "Borrow"

    /// Effect on the chosen account when the money first changes hands.
    func principalDelta(_ amount: Double) -> Double {
        self == .lent ? -amount : amount
    }

    /// Effect on the chosen account when a repayment is recorded.
    func repaymentDelta(_ amount: Double) -> Double {
        self == .lent ? amount : -amount
    }
}

// MARK: - Repayment

struct Repayment: Identifiable, Hashable {
    let id: UUID
    let amount: Double
    let date: Date
    /// Where the money went to (lent) or came from (borrowed).
    let account: AccountSummary
    let note: String?

    init(id: UUID = UUID(),
         amount: Double,
         date: Date = .now,
         account: AccountSummary,
         note: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.account = account
        self.note = note
    }
}

// MARK: - Installment

/// One scheduled payment. Repayments are applied to installments in order,
/// so paying ahead automatically covers the next ones.
struct Installment: Identifiable, Hashable {
    let number: Int
    let dueDate: Date
    let amount: Double
    let paid: Double

    var id: Int { number }
    var remaining: Double { max(amount - paid, 0) }
    var isPaid: Bool { remaining < Loan.tolerance }
}

// MARK: - Status

enum LoanStatus: Hashable {
    case settled
    case overdue(days: Int)
    case due(inDays: Int)      // 0 = today
    case open                  // no due date

    var overdueDays: Int? {
        if case .overdue(let days) = self { return days }
        return nil
    }

    /// Sort key for "what needs attention first".
    var dueRank: Int {
        if case .due(let days) = self { return days }
        return Int.max
    }
}

// MARK: - Loan

struct Loan: Identifiable, Hashable {

    /// Amounts are entered with two decimals; anything below this is rounding noise.
    static let tolerance = 0.005
    static let maxInstallments = 60

    let id: UUID
    let kind: LoanKind
    var personID: Person.ID
    /// The account the principal moved through. Snapshot, like `Transfer`.
    let account: AccountSummary
    let principal: Double
    /// Extra amount to repay on top of the principal (interest / fee).
    var interest: Double
    var date: Date
    /// First (or only) due date. `nil` = open-ended.
    var dueDate: Date?
    /// Monthly installments counted from `dueDate`. `1` = single payment.
    var installmentCount: Int
    var note: String?
    var repayments: [Repayment]

    init(id: UUID = UUID(),
         kind: LoanKind,
         personID: Person.ID,
         account: AccountSummary,
         principal: Double,
         interest: Double = 0,
         date: Date = .now,
         dueDate: Date? = nil,
         installmentCount: Int = 1,
         note: String? = nil,
         repayments: [Repayment] = []) {
        self.id = id
        self.kind = kind
        self.personID = personID
        self.account = account
        self.principal = principal
        self.interest = interest
        self.date = date
        self.dueDate = dueDate
        self.installmentCount = max(installmentCount, 1)
        self.note = note
        self.repayments = repayments
    }

    // MARK: Amounts

    var totalPayable: Double { principal + interest }
    var totalRepaid: Double { repayments.reduce(0) { $0 + $1.amount } }
    var outstanding: Double { max(totalPayable - totalRepaid, 0) }
    var isSettled: Bool { outstanding < Self.tolerance }
    var progress: Double { totalPayable > 0 ? min(totalRepaid / totalPayable, 1) : 0 }
    var lastActivity: Date { max(date, repayments.map(\.date).max() ?? date) }

    // MARK: Schedule

    func installments(calendar: Calendar = .current) -> [Installment] {
        guard let dueDate else { return [] }

        let count = max(installmentCount, 1)
        let total = totalPayable
        let base = (total / Double(count) * 100).rounded(.down) / 100

        var unallocatedPayment = totalRepaid
        var allocated = 0.0
        var result: [Installment] = []
        result.reserveCapacity(count)

        for index in 0..<count {
            // The last installment absorbs the rounding remainder.
            let amount = index == count - 1
                ? ((total - allocated) * 100).rounded() / 100
                : base
            allocated += amount

            let paid = min(max(unallocatedPayment, 0), amount)
            unallocatedPayment -= paid

            let due = calendar.date(byAdding: .month, value: index, to: dueDate) ?? dueDate
            result.append(Installment(number: index + 1, dueDate: due, amount: amount, paid: paid))
        }
        return result
    }

    func nextInstallment(calendar: Calendar = .current) -> Installment? {
        installments(calendar: calendar).first { !$0.isPaid }
    }

    /// What should already have been paid before `limit` and still isn't.
    func amountDue(before limit: Date, calendar: Calendar = .current) -> Double {
        guard !isSettled else { return 0 }
        return installments(calendar: calendar)
            .filter { $0.dueDate < limit }
            .reduce(0) { $0 + $1.remaining }
    }

    func status(now: Date = .now, calendar: Calendar = .current) -> LoanStatus {
        guard !isSettled else { return .settled }
        guard let next = nextInstallment(calendar: calendar) else { return .open }

        let today = calendar.startOfDay(for: now)
        let due = calendar.startOfDay(for: next.dueDate)
        let days = calendar.dateComponents([.day], from: today, to: due).day ?? 0
        return days < 0 ? .overdue(days: -days) : .due(inDays: days)
    }
}

// MARK: - Presentation row

/// A loan joined with its person and computed status, built once per refresh
/// so rows never recompute schedules while scrolling.
struct LoanItem: Identifiable, Hashable {
    let loan: Loan
    let person: Person
    let status: LoanStatus

    var id: Loan.ID { loan.id }
}

extension LoanItem {
    init(loan: Loan, person: Person?, now: Date = .now, calendar: Calendar = .current) {
        self.loan = loan
        self.person = person ?? .unknown(id: loan.personID)
        self.status = loan.status(now: now, calendar: calendar)
    }
}
