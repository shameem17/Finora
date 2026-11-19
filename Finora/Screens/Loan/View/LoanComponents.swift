//
//  LoanComponents.swift
//  Finora
//
//  Screens/Loan/View
//

import SwiftUI

// MARK: - Presentation helpers (copy + colours live in the view layer)

extension LoanKind {
    var tint: CustomColor { self == .lent ? .accent : .accent }

    /// "Borrower" / "Lender"
    var personRole: String { self == .lent ? "Borrower" : "Lender" }

    var addTitle: String { self == .lent ? "Add New Loan" : "Add New Borrow" }

    /// Account the principal moves through.
    var accountFieldTitle: String { self == .lent ? "Paid from" : "Received in" }

    /// Account a repayment moves through (the opposite direction).
    var repaymentAccountTitle: String { self == .lent ? "Received in" : "Paid from" }

    var repaymentActionTitle: String { self == .lent ? "Record Received" : "Record Payment" }
    var repaymentsHeading: String { self == .lent ? "Repayments received" : "Payments made" }
    var outstandingCaption: String { self == .lent ? "Still to receive" : "Still to pay" }
    var typeDescription: String { self == .lent ? "Loan given" : "Money borrowed" }

    var emptyTitle: String { self == .lent ? "No loans yet" : "No borrowings yet" }
    var emptyMessage: String {
        self == .lent
        ? "Money you lend to friends, family or others will be tracked here."
        : "Money you borrow from people, banks or wallets will be tracked here."
    }
}

extension LoanStatus {
    var label: String? {
        switch self {
        case .settled:
            return "Settled"
        case .overdue(let days):
            return days == 1 ? "Overdue 1 day" : "Overdue \(days) days"
        case .due(let days):
            switch days {
            case 0:  return "Due today"
            case 1:  return "Due tomorrow"
            default: return "Due in \(days) days"
            }
        case .open:
            return nil
        }
    }

    var color: Color {
        switch self {
        case .settled:
            return Color.positive
        case .overdue:
            return Color.negative
        case .due(let days):
            return days <= 7 ? Color.textPrimary : Color.textSecondary
        case .open:
            return Color.textSecondary
        }
    }
}

extension ReportPeriod {
    /// Reads naturally after a verb: "Activity this month".
    var phrase: String {
        switch self {
        case .week:  return "this week"
        case .month: return "this month"
        case .year:  return "this year"
        case .all:   return "all time"
        }
    }
}

// MARK: - Avatar

struct PersonAvatar: View {
    let person: Person
    var size: CGFloat = 46

    private var tint: Color { Color.brandSecondary }

    var body: some View {
        Group {
            if person.category == .individual {
                Text(person.initials)
                    .font(.manrope, size: size * 0.36, weight: .extraBold)
            } else {
                Image(systemName: person.category.icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
            }
        }
        .foregroundStyle(tint)
        .frame(width: size, height: size)
        .background(tint.opacity(0.15), in: Circle())
        .accessibilityHidden(true)
    }
}

// MARK: - Chip

struct StatusChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.manrope, size: 11, weight: .bold)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
    }
}

// MARK: - Row

struct LoanRow: View {
    let item: LoanItem

    private var loan: Loan { item.loan }
    private var isSettled: Bool { item.status == .settled }
    private var showsProgress: Bool { !isSettled && loan.totalRepaid > 0 }

    private var subtitle: String {
        let date = loan.date.formatted(.dateTime.day().month(.abbreviated))
        return "\(loan.account.name) · \(date)"
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                PersonAvatar(person: item.person, size: 46)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.person.name)
                        .font(.manrope, size: 15, weight: .bold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(subtitle)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(CurrencyFormatter.taka(isSettled ? loan.totalPayable : loan.outstanding,
                                                showFraction: true))
                        .font(.manrope, size: 15, weight: .extraBold)
                        .foregroundStyle(Color.textPrimary.opacity(isSettled ? 0.5 : 1))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if let label = item.status.label {
                        StatusChip(text: label, color: item.status.color)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.textTertiary)
            }

            if showsProgress {
                HStack(spacing: 10) {
                    ProgressBar(fraction: loan.progress, color: loan.kind.tint.color)

                    Text("\(Int((loan.progress * 100).rounded()))% repaid")
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize()
                }
                .padding(.leading, 60)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Empty state

struct LoanEmptyState: View {
    let kind: LoanKind
    let isSearching: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isSearching ? "magnifyingglass" : "banknote")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.textTertiary)

            Text(isSearching ? "No matches" : kind.emptyTitle)
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Text(isSearching ? "Try a different name or note." : kind.emptyMessage)
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}
