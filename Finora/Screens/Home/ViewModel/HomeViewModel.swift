//
//  HomeViewModel.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import Foundation
import SwiftUI
import Combine

protocol HomeViewModelProtocol {
   func prepareData()
   var homeViewData: HomeViewData? { get }
}

enum SummaryType: CaseIterable {
   case income, expense, balance

   var name: String {
       switch self {
       case .income:  return "Income"
       case .expense: return "Expense"
       case .balance: return "Balance"
       }
   }

   var brandColor: CustomColor {
       switch self {
       case .income, .expense, .balance: return .secondary
       }
   }
}

// MARK: - Insights model

/// Month-to-date numbers that drive both the overview tiles and the insights card.
struct MonthlyInsights: Equatable {
   enum Pace: Equatable {
       case onTrack(surplus: Double)
       case overspending(deficit: Double)
   }

   let income: Double
   let expense: Double
   let previousMonthExpense: Double
   let elapsedDays: Int
   let totalDays: Int
   let topExpense: BreakdownItem

   var balance: Double { income - expense }

   /// 0...1, share of income not spent.
   var savingsRate: Double {
       guard income > 0 else { return 0 }
       return min(max(balance / income, 0), 1)
   }

   var dailyAverage: Double {
       elapsedDays > 0 ? expense / Double(elapsedDays) : 0
   }

   /// Month-end spend if the current daily average continues.
   var projectedExpense: Double { dailyAverage * Double(totalDays) }

   var pace: Pace {
       let diff = income - projectedExpense
       return diff >= 0 ? .onTrack(surplus: diff) : .overspending(deficit: -diff)
   }

   /// Fractional change vs last month (-0.16 = 16% less). `nil` without history.
   var expenseChange: Double? {
       guard previousMonthExpense > 0 else { return nil }
       return (expense - previousMonthExpense) / previousMonthExpense
   }

   func amount(for type: SummaryType) -> Double {
       switch type {
       case .income:  return income
       case .expense: return expense
       case .balance: return balance
       }
   }
}

extension MonthlyInsights {
   /// Previews only. The app computes real insights from stored entries.
   static func sample(progress: MonthProgress) -> MonthlyInsights {
       MonthlyInsights(
           income: 85_000,
           expense: 41_250,
           previousMonthExpense: 48_900,
           elapsedDays: progress.elapsedDays,
           totalDays: progress.totalDays,
           topExpense: .init(name: "Food",
                             amount: 12_400,
                             color: Color.brandSecondary,
                             icon: "fork.knife")
       )
   }

   static let sample = sample(progress: MonthProgress(elapsedDays: 12, totalDays: 30))
}

// MARK: - View data

struct HomeViewData {
   let headerTitle: String
   let accounts: [Account]
   let insights: MonthlyInsights
   let overview: FinanceOverview
}


@Observable
final class HomeViewModel: HomeViewModelProtocol {

   var homeViewData: HomeViewData?

   // services
   let dateService: DateServiceProtocol
   private let accountRepository: AccountRepositoryProtocol
   private let cashFlowRepository: CashFlowRepositoryProtocol
   private let categoryRepository: CategoryRepositoryProtocol
   private let loanRepository: LoanRepositoryProtocol
   private let savingsRepository: SavingsRepositoryProtocol
   private let calendar: Calendar

   @ObservationIgnored private var cancellables = Set<AnyCancellable>()

   init(dateService: DateServiceProtocol = DateService(),
        accountRepository: AccountRepositoryProtocol = SwiftDataAccountRepository.shared,
        cashFlowRepository: CashFlowRepositoryProtocol = SwiftDataCashFlowRepository.shared,
        categoryRepository: CategoryRepositoryProtocol = SwiftDataCategoryRepository.shared,
        loanRepository: LoanRepositoryProtocol = SwiftDataLoanRepository.shared,
        savingsRepository: SavingsRepositoryProtocol = SwiftDataSavingsRepository.shared,
        calendar: Calendar = .current) {
       self.dateService = dateService
       self.accountRepository = accountRepository
       self.cashFlowRepository = cashFlowRepository
       self.categoryRepository = categoryRepository
       self.loanRepository = loanRepository
       self.savingsRepository = savingsRepository
       self.calendar = calendar

       // Keep balances and insights in sync with edits made on any other tab.
       accountRepository.changes
           .merge(with: cashFlowRepository.changes,
                  categoryRepository.changes,
                  loanRepository.changes,
                  savingsRepository.changes)
           .sink { [weak self] in
               guard self?.homeViewData != nil else { return }
               self?.prepareData()
           }
           .store(in: &cancellables)
   }

   func prepareData() {
       let date = dateService.currentDate()
       let accounts = accountRepository.fetchAccounts()
       let insights = makeInsights()
       homeViewData = HomeViewData(
           headerTitle: "\(date.month) \(date.year), Overview",
           accounts: accounts,
           insights: insights,
           overview: FinanceOverview.make(accounts: accounts,
                                          loans: loanRepository.fetchLoans(),
                                          savings: savingsRepository.fetchSavings(),
                                          monthBalance: insights.balance)
       )
   }

   // MARK: Private

   private func makeInsights() -> MonthlyInsights {
       let now = Date.now
       let previous = calendar.date(byAdding: .month, value: -1, to: now) ?? now
       let calendar = self.calendar

       func inMonth(_ reference: Date) -> (CashFlowEntry) -> Bool {
           { calendar.isDate($0.date, equalTo: reference, toGranularity: .month) }
       }

       let income = cashFlowRepository.fetchEntries(kind: .income)
           .filter(inMonth(now))
           .reduce(0) { $0 + $1.amount }

       let expenses = cashFlowRepository.fetchEntries(kind: .expense)
       let monthExpenses = expenses.filter(inMonth(now))
       let expense = monthExpenses.reduce(0) { $0 + $1.amount }
       let previousExpense = expenses.filter(inMonth(previous)).reduce(0) { $0 + $1.amount }

       let categories = Dictionary(categoryRepository.fetchCategories(kind: .expense).map { ($0.id, $0) },
                                   uniquingKeysWith: { first, _ in first })

       let top = Dictionary(grouping: monthExpenses, by: \.categoryID)
           .map { id, group -> BreakdownItem in
               let amount = group.reduce(0) { $0 + $1.amount }
               if let category = categories[id] {
                   return BreakdownItem(name: category.name, amount: amount,
                                        color: Color(hex: category.tint), icon: category.icon)
               }
               return BreakdownItem(name: "Uncategorised", amount: amount,
                                    color: Color.textTertiary, icon: "questionmark.circle")
           }
           .max { $0.amount < $1.amount }
           ?? BreakdownItem(name: "None yet", amount: 0, color: Color.textTertiary, icon: "minus")

       let progress = dateService.monthProgress()
       return MonthlyInsights(income: income,
                              expense: expense,
                              previousMonthExpense: previousExpense,
                              elapsedDays: progress.elapsedDays,
                              totalDays: progress.totalDays,
                              topExpense: top)
   }
}
