//
//  DateService.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import Foundation

struct DateData{
    let day: String
    let month: String
    let year: String
}

protocol DateServiceProtocol {
    func currentDate() -> DateData
    
}


struct DateService: DateServiceProtocol {
    func currentDate() -> DateData {
        let date = Date()
        let calendar = Calendar.current
        return calendar.getDateComponents(from: date)
        
    }
}

extension Calendar{
    func getDateComponents(from date: Date) -> DateData {
        let month = component(.month, from: date)
        let year = component(.year, from: date)
        return DateData(day: dayName(for: date), month: monthName(for: month), year: "\(year)")
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        let monthSymbols = formatter.monthSymbols
        return monthSymbols?[month - 1] ?? ""
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

}
