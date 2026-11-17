//
//  SavingsRouting.swift
//  Finora
//
//  Screens/Savings/Coordinator
//

import Foundation

/// What the Savings view models may ask the coordinator to do.
protocol SavingsRouting: AnyObject {
    func showDetail(of id: SavingsAccount.ID)
    func closeDetail()
}
