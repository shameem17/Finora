//
//  LoanView.swift
//  Finora
//
//  Screens/Loan/View
//
//  Hosted by LoanCoordinator inside its UINavigationController, so there is no
//  NavigationStack here: title and toolbar bridge to the UIKit bar.
//

import SwiftUI

struct LoanView<ViewModel: LoanViewModelProtocol>: View {

    @Bindable var model: ViewModel
    @State private var form: LoanFormViewModel?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    PillPicker(selection: $model.period)
                    LoanSummaryCard(period: model.period, summary: model.summary)
                    list
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .animation(.smooth, value: model.period)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Loans")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.showPeople()
                } label: {
                    Image(systemName: "person.2.fill")
                }
                .accessibilityLabel("People")
            }
        }
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: model.kind.addTitle) {
                form = model.makeFormViewModel()
            }
        }
        .task { model.load() }
        .sheet(item: $form) { LoanFormView(form: $0) }
    }

    // MARK: - List

    private var list: some View {
        VStack(spacing: 16) {
            PillPicker(selection: $model.kind)

            if !model.isEmpty {
                SearchField(text: $model.searchText, prompt: "Search by name or note")
            }

            if model.sections.isEmpty {
                LoanEmptyState(kind: model.kind,
                               isSearching: !model.isEmpty && !model.searchText.isEmpty)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(model.sections) { section in
                        sectionView(section)
                    }
                }
            }
        }
        .animation(.smooth, value: model.kind)
    }

    private func sectionView(_ section: LoanSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(section.group.title)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(section.group == .overdue
                                     ? CustomColor.dangerRed.color
                                     : CustomColor.darkGray.color.opacity(0.7))

                Text("\(section.items.count)")
                    .font(.manrope, size: 12, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(CustomColor.darkGray.color.opacity(0.06), in: Capsule())
            }
            .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    Button {
                        model.showDetail(of: item)
                    } label: {
                        LoanRow(item: item)
                    }
                    .buttonStyle(.plain)

                    if item.id != section.items.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .finoraCard(cornerRadius: 24)
        }
    }
}

#Preview {
    NavigationStack {
        LoanView(model: LoanViewModel(dependencies: .preview()))
    }
}
