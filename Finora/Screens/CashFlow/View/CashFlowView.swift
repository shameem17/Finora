//
//  CashFlowView.swift
//  Finora
//
//  Screens/CashFlow/View
//
//  The Income and the Expense screen. Hosted by its coordinator inside a
//  UINavigationController, so the title bridges to the UIKit bar.
//

import SwiftUI

struct CashFlowView<ViewModel: CashFlowViewModelProtocol>: View {

    @Bindable var model: ViewModel
    @State private var form: CashFlowFormViewModel?

    private var kind: CategoryKind { model.kind }

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    PillPicker(selection: $model.period)

                    if model.items.isEmpty {
                        EmptyStateCard(icon: kind == .income ? "arrow.down.circle" : "arrow.up.circle",
                                       title: "No \(kind.singular) yet",
                                       message: "Nothing recorded for \(model.period.subtitle.lowercased()). Tap “\(kind.addTitle)” to add one.")
                    } else {
                        DonutCard(title: kind.totalTitle,
                                  subtitle: model.period.subtitle,
                                  centerCaption: kind.centerCaption,
                                  items: model.items)

                        entriesCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .animation(.smooth, value: model.period)
            }
        }
        .navigationTitle(kind.screenTitle)
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: kind.addTitle, tint: kind.tint) {
                form = model.makeFormViewModel(editing: nil)
            }
        }
        .task { model.load() }
        .sheet(item: $form) { CashFlowFormView(form: $0) }
    }

    private var entriesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(kind == .income ? "Recent income" : "Recent expenses")

            ForEach(model.entries) { item in
                Button {
                    form = model.makeFormViewModel(editing: item.entry)
                } label: {
                    CashFlowRow(item: item)
                }
                .buttonStyle(.plain)

                if item.id != model.entries.last?.id { Divider() }
            }
        }
        .sectionCard()
    }
}

struct CashFlowRow: View {
    let item: CashFlowItem

    private var entry: CashFlowEntry { item.entry }

    var body: some View {
        HStack(spacing: 12) {
            CategoryIconBadge(icon: item.category?.icon ?? "questionmark.circle",
                              tint: item.category?.tint ?? Palette.secondaryHex,
                              size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category?.name ?? "Uncategorised")
                    .font(.manrope, size: 14, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(item.account?.name ?? "Account removed") · \(entry.date.shortDisplay)")
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            Spacer(minLength: 8)

            Text("\(entry.kind == .income ? "+" : "−")\(CurrencyFormatter.taka(entry.amount, showFraction: true))")
                .font(.manrope, size: 15, weight: .extraBold)
                .foregroundStyle(entry.kind == .income ? Color.positive : Color.negative)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Edit")
    }
}

#Preview {
    NavigationStack {
        CashFlowView(model: CashFlowViewModel(kind: .expense, dependencies: .preview()))
    }
}
