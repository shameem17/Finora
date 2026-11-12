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
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        case .balance:
            return "Balance"
        }
    }
    
    var brandColor: CustomColor {
        switch self {
        case .income:
            return .successGreen
        case .expense:
            return .dangerRed
        case .balance:
            return .darkGray
        }
    }
}

struct HomeViewData{
    let headerTitle: String
    let accounts: [Account]
    
}


@Observable
final class HomeViewModel: HomeViewModelProtocol {

    var homeViewData: HomeViewData?
    
    
    // services
    let dateService: DateServiceProtocol
    
    private let accounts: [Account] = [
        .init(name: "City Bank",  number: "1234567894821",    type: .bank,    balance: 125_450.75, logo: "citybank", tint: "#007366"),
        .init(name: "bKash",      number: "01712345678",      type: .mfs,     balance: 8_320,       logo: "bkash",    tint: "#E31266"),
        .init(name: "Nagad",      number: "01898765432",      type: .mfs,     balance: 2_150.5,     logo: "nagad",    tint: "#F2661A"),
        .init(name: "PayPal",     number: "ab@mail.com 9921", type: .online,  balance: 640,         logo: "paypal",   tint: "#1A4DB3"),
        .init(name: "Payoneer",   number: "PY00551234",       type: .virtual, balance: 15_900,      logo: nil,        tint: "#6640D9"),
        .init(name: "Visa Debit", number: "4111111111113344", type: .card,    balance: 42_000,      logo: nil,        tint: "#1F2433")
    ]
    
    
    init(dateService: DateServiceProtocol = DateService()) {
        self.dateService = dateService
    }
    
    func prepareData() {
        let date = dateService.currentDate()
        homeViewData = HomeViewData(headerTitle: date.month + " " + String(date.year) + ", " + "Overview", accounts: accounts)
        print("data set")
    }
    
    
    
}
