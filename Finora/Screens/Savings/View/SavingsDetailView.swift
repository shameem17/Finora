//
//  SavingsDetailView.swift
//  Finora
//
//  Screens/Savings/View
//

import SwiftUI

struct SavingsDetailView<ViewModel: SavingsDetailViewModelProtocol>: View {

    let model: ViewModel

    @State private var entryForm: SavingsEntryFormViewModel?
    @State private var entryEditForm: SavingsEntryFormViewModel?
    @State private var log: SavingsLogViewModel?
    @State private var editForm: SavingsFormViewModel?
    @State private var confirmDelete = false
    @State private var entryToDelete: SavingsEntry?
    @State private var entryDeleteFailed = false

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            if let item = model.item {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header(item.savings)
                        details(item)
                        history
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: item)
                }
            }
        }
        .navigationTitle(model.item?.savings.name ?? "Savings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.item != nil {
                ToolbarItem(placement: .topBarTrailing) { menu }
            }
        }
        .safeAreaInset(edge: .bottom) { bottomActions }
        .task { model.load() }
        .sheet(item: $entryForm) { SavingsEntryFormView(form: $0) }
        .sheet(item: $entryEditForm) { SavingsEntryFormView(form: $0) }
        .sheet(item: $log) { SavingsLogView(model: $0, isSheet: true) }
        .sheet(item: $editForm) { SavingsFormView(form: $0) }
        .confirmationDialog("Delete this savings account?",
                            isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            if let savings = model.item?.savings, savings.currentSavings > 0 {
                Button("Delete & return \(CurrencyFormatter.taka(savings.currentSavings, showFraction: true))", role: .destructive) {
                    model.deleteSavings(returnRemaining: true)
                }
            }
            Button("Delete only", role: .destructive) {
                model.deleteSavings(returnRemaining: false)
            }
        } message: {
            Text("Returning sends what's left back to \(model.item?.account?.name ?? "its account"). “Delete only” leaves all account balances as they are.")
        }
        .confirmationDialog("Delete this entry?",
                            isPresented: Binding(get: { entryToDelete != nil },
                                                 set: { if !$0 { entryToDelete = nil } }),
                            titleVisibility: .visible,
                            presenting: entryToDelete) { entry in
            Button("Delete", role: .destructive) {
                if !model.deleteEntry(id: entry.id) { entryDeleteFailed = true }
            }
        } message: { entry in
            if let account = entry.account {
                Text("The \(account.name) balance is adjusted back by \(CurrencyFormatter.taka(entry.amount, showFraction: true)).")
            } else {
                Text("No account balance is affected.")
            }
        }
        .alert("Can't delete this entry", isPresented: $entryDeleteFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Removing it would leave you with more withdrawn than saved.")
        }
    }

    // MARK: - Toolbar / bottom

    private var menu: some View {
        Menu {
            Button {
                editForm = model.makeEditFormViewModel()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                confirmDelete = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .accessibilityLabel("More")
    }

    private var bottomActions: some View {
        HStack(spacing: 12) {
            Button {
                entryForm = model.makeEntryFormViewModel(kind: .withdrawal)
            } label: {
                Label("Withdraw", systemImage: SavingsEntryKind.withdrawal.icon)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.fillSubtle, in: Capsule())
            }
            .disabled((model.item?.savings.currentSavings ?? 0) <= 0)

            Button {
                entryForm = model.makeEntryFormViewModel(kind: .deposit)
            } label: {
                Label("Add Savings", systemImage: SavingsEntryKind.deposit.icon)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.onAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandAccent, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - Header

    private func header(_ savings: SavingsAccount) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                SavingsLogo(name: savings.name, tint: savings.tint, logoData: savings.logoData, size: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT SAVINGS")
                        .font(.manrope, size: 11, weight: .semiBold)
                        .tracking(1)
                        .foregroundStyle(Color.textSecondary)

                    Text(CurrencyFormatter.taka(savings.currentSavings, showFraction: true))
                        .font(.manrope, size: 30, weight: .extraBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 0)
            }

            if let progress = savings.progress, let target = savings.target {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressBar(fraction: progress, color: Color(hex: savings.tint))
                    HStack {
                        Text("\(Int((progress * 100).rounded()))% of \(CurrencyFormatter.taka(target))")
                        Spacer()
                        if savings.isGoalReached {
                            Label("Goal reached", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Color.positive)
                        } else if let remaining = savings.remainingToTarget {
                            Text("\(CurrencyFormatter.taka(remaining, showFraction: true)) to go")
                        }
                    }
                    .font(.manrope, size: 12, weight: .semiBold)
                    .foregroundStyle(Color.textSecondary)
                }
            }

            Divider()

            HStack(alignment: .top) {
                StatColumn(title: "Total saved", value: CurrencyFormatter.taka(savings.totalDeposited, showFraction: true))
                StatColumn(title: "Withdrawn", value: CurrencyFormatter.taka(savings.totalWithdrawn, showFraction: true))
            }
        }
        .sectionCard()
    }

    // MARK: - Details

    private func details(_ item: SavingsItem) -> some View {
        let savings = item.savings
        return VStack(spacing: 12) {
            ValueRow(title: "Tagged account", value: item.account?.name ?? "—")

            if !savings.number.isEmpty {
                ValueRow(title: "Account no.", value: savings.number)
            }

            ValueRow(title: "Started", value: savings.startDate.shortDisplay)

            if let due = savings.targetDate {
                ValueRow(title: "Target date", value: due.shortDisplay)
            }

            if let target = savings.target {
                ValueRow(title: "Target", value: CurrencyFormatter.taka(target, showFraction: true))
            }

            if savings.openingBalance > 0 {
                ValueRow(title: "Opening balance", value: CurrencyFormatter.taka(savings.openingBalance, showFraction: true))
            }

            if !savings.note.isEmpty {
                ValueRow(title: "Note", value: savings.note)
            }
        }
        .padding(16)
        .finoraCard(cornerRadius: 22)
    }

    // MARK: - History

    private var history: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionLabel("History")
                Spacer()
                if !model.entries.isEmpty {
                    Button { log = model.makeLogViewModel() } label: {
                        Text("Full log")
                            .font(.manrope, size: 13, weight: .bold)
                            .foregroundStyle(Color.brandAccent)
                    }
                }
            }

            if model.entries.isEmpty {
                Text("No deposits or withdrawals yet.")
                    .font(.manrope, size: 14, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            } else {
                ForEach(model.entries) { entry in
                    SavingsEntryRow(entry: entry)
                        .contentShape(Rectangle())
                        .onTapGesture { entryEditForm = model.makeEditEntryFormViewModel(entry) }
                        .contextMenu {
                            Button { entryEditForm = model.makeEditEntryFormViewModel(entry) } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) { entryToDelete = entry } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    if entry.id != model.entries.last?.id { Divider() }
                }
                Text("Tap an entry to edit it, touch and hold to delete.")
                    .font(.manrope, size: 11, weight: .medium)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .sectionCard()
    }
}

#Preview {
    let dependencies = SavingsDependencies.preview()
    if let first = dependencies.savings.fetchSavings().first {
        NavigationStack {
            SavingsDetailView(model: SavingsDetailViewModel(savingsID: first.id, dependencies: dependencies))
        }
    }
}
