//
//  IncomeViewModel.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import Foundation
import Combine
import Observation


private extension ReportPeriod {
    /// DEMO ONLY: scales the sample data.
    var demoMultiplier: Double {
        switch self {
        case .week:  return 0.25
        case .month: return 1
        case .year:  return 11
        case .all:   return 18
        }
    }
}

@Observable
final class IncomeViewModel {
    var period: ReportPeriod = .month

    /// Slices for the selected period, largest first.
    var items: [BreakdownItem] {
        baseItems
            .map { BreakdownItem(name: $0.name,
                                 amount: ($0.amount * period.demoMultiplier).rounded(),
                                 color: $0.color,
                                 icon: $0.icon) }
            .sorted { $0.amount > $1.amount }
    }

    // DEMO ONLY: replace with a repository query filtered by `period`.
    private let baseItems = BreakdownItem.sampleIncome
}
