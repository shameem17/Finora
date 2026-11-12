//
//  Accounts.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//

import Foundation


struct Account: Identifiable {
    let id = UUID()
    let name: String
    let number: String
    let type: AccountType
    let balance: Double
    let logo: String?
    let tint: String
}
