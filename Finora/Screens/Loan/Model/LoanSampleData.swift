//
//  LoanSampleData.swift
//  Finora
//
//  Screens/Loan/Model
//
//  Debug / preview data only. Compiled out of Release builds.
//

#if DEBUG
import Foundation

enum LoanSampleData {

    static let people: [Person] = [
        Person(name: "Rahim Uddin", phone: "01711000111", address: "Mirpur 10, Dhaka"),
        Person(name: "Karim Hossain", phone: "01811000222"),
        Person(name: "Sabrina Akter"),
        Person(name: "Mamun Hasan", phone: "01911000333", address: "Uttara, Dhaka"),
        Person(name: "City Bank", category: .bank),
        Person(name: "bKash", category: .wallet)
    ]

    static func loans(people: [Person],
                      accounts: [Account],
                      calendar: Calendar = .current,
                      now: Date = .now) -> [Loan] {

        func person(_ name: String) -> Person? { people.first { $0.name == name } }
        func account(_ name: String) -> AccountSummary? {
            (accounts.first { $0.name == name } ?? accounts.first).map { AccountSummary($0) }
        }
        func day(_ offset: Int) -> Date {
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now) ?? now)
        }

        guard let rahim = person("Rahim Uddin"),
              let karim = person("Karim Hossain"),
              let sabrina = person("Sabrina Akter"),
              let mamun = person("Mamun Hasan"),
              let bank = person("City Bank"),
              let cityBank = account("City Bank"),
              let bkash = account("bKash"),
              let cash = account("Cash")
        else { return [] }

        return [
            // Overdue, partly repaid
            Loan(kind: .lent, personID: rahim.id, account: cityBank, principal: 20_000,
                 date: day(-30), dueDate: day(-5), note: "Shop renovation",
                 repayments: [Repayment(amount: 5_000, date: day(-10), account: cityBank)]),

            // Due in two weeks
            Loan(kind: .lent, personID: karim.id, account: bkash, principal: 5_000,
                 date: day(-3), dueDate: day(12)),

            // Open-ended
            Loan(kind: .lent, personID: mamun.id, account: cash, principal: 1_500,
                 date: day(-8), note: "Lunch + taxi"),

            // Settled
            Loan(kind: .lent, personID: sabrina.id, account: cash, principal: 12_000,
                 date: day(-90),
                 repayments: [Repayment(amount: 12_000, date: day(-40), account: cash)]),

            // Bank loan, 6 monthly installments, first one paid
            Loan(kind: .borrowed, personID: bank.id, account: cityBank, principal: 60_000,
                 interest: 6_000, date: day(-75), dueDate: day(-15), installmentCount: 6,
                 note: "Personal loan",
                 repayments: [Repayment(amount: 11_000, date: day(-20), account: cityBank)]),

            // Short-term borrow from a friend
            Loan(kind: .borrowed, personID: mamun.id, account: bkash, principal: 3_000,
                 date: day(-6), dueDate: day(3), note: "Phone recharge + bills")
        ]
    }
}
#endif
