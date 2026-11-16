//
//  CategoryFormViewModel.swift
//  Finora
//
//  Screens/Categories/ViewModel
//

import Foundation
import Observation

@Observable
final class CategoryFormViewModel: Identifiable {

    enum Mode {
        case create(kind: CategoryKind)
        case edit(TransactionCategory)
    }

    let id = UUID()
    let mode: Mode
    let kind: CategoryKind

    var name = ""
    var icon: String
    var tintHex: String
    var budgetText = ""

    private(set) var error: String?

    @ObservationIgnored private let repository: CategoryRepositoryProtocol

    init(mode: Mode, repository: CategoryRepositoryProtocol) {
        self.mode = mode
        self.repository = repository

        switch mode {
        case .create(let kind):
            self.kind = kind
            icon = kind.icons[0]
            tintHex = kind == .income ? "#28A745" : "#FF6B6B"
        case .edit(let category):
            kind = category.kind
            name = category.name
            icon = category.icon
            tintHex = category.tint
            if let budget = category.monthlyBudget {
                budgetText = budget.truncatingRemainder(dividingBy: 1) == 0
                    ? String(Int(budget)) : String(budget)
            }
        }
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String {
        (isEditing ? "Edit " : "New ") + kind.title + " Category"
    }

    var supportsBudget: Bool { kind == .expense }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var editingID: TransactionCategory.ID? {
        if case .edit(let category) = mode { return category.id }
        return nil
    }

    private var budget: Double? {
        let value = DecimalInput.value(of: budgetText)
        return value > 0 ? value : nil
    }

    var canSubmit: Bool { !trimmedName.isEmpty }

    var draft: TransactionCategory {
        TransactionCategory(id: editingID ?? UUID(),
                            name: trimmedName.isEmpty ? "Category name" : trimmedName,
                            kind: kind, icon: icon, tint: tintHex,
                            monthlyBudget: supportsBudget ? budget : nil)
    }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit else { return false }

        let duplicate = repository.fetchCategories(kind: kind).contains {
            $0.id != editingID &&
            $0.name.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard !duplicate else {
            error = "You already have a \(kind.singular) category named “\(trimmedName)”."
            return false
        }
        error = nil

        let category = TransactionCategory(id: editingID ?? UUID(),
                                           name: trimmedName, kind: kind,
                                           icon: icon, tint: tintHex,
                                           monthlyBudget: supportsBudget ? budget : nil)
        if isEditing { repository.update(category) } else { repository.add(category) }
        return true
    }

    func delete() {
        guard let editingID else { return }
        repository.delete(id: editingID)
    }

    func clearError() { error = nil }
}
