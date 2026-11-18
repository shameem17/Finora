//
//  HomeViewModel.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//


import Foundation
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
   // DEMO ONLY: replace with a repository query.
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
}


@Observable
final class HomeViewModel: HomeViewModelProtocol {

   var homeViewData: HomeViewData?

   // services
   let dateService: DateServiceProtocol
   private let accountRepository: AccountRepositoryProtocol

   @ObservationIgnored private var cancellables = Set<AnyCancellable>()

   init(dateService: DateServiceProtocol = DateService(),
        accountRepository: AccountRepositoryProtocol = InMemoryAccountRepository.shared) {
       self.dateService = dateService
       self.accountRepository = accountRepository

       // Keep the account cards in sync with edits made on the Accounts tab.
       accountRepository.changes
           .sink { [weak self] in
               guard self?.homeViewData != nil else { return }
               self?.prepareData()
           }
           .store(in: &cancellables)
   }

   func prepareData() {
       let date = dateService.currentDate()
       homeViewData = HomeViewData(
           headerTitle: "\(date.month) \(date.year), Overview",
           accounts: accountRepository.fetchAccounts(),
           insights: .sample(progress: dateService.monthProgress())
       )
   }
}
