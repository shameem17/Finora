//
//  LoanRouting.swift
//  Finora
//
//  Screens/Loan/Coordinator
//

import Foundation

/// What the Loan view models may ask the coordinator to do. View models never
/// touch UIKit; the coordinator owns every push / pop.
protocol LoanRouting: AnyObject {
    func showDetail(of loanID: Loan.ID)
    func showPeople()
    func closeDetail()
}
