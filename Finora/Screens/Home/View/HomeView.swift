//
//  SummaryCard.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//


import SwiftUI
 
protocol PickerOption: CaseIterable, Identifiable, Hashable where ID == Self {
    var title: String { get }
}
 
extension PickerOption {
    var id: Self { self }                 // enums don't need to repeat this
}
 
// Default title for String-backed enums
extension PickerOption where Self: RawRepresentable, RawValue == String {
    var title: String { rawValue }
}
 
struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    let model: ViewModel
 
 
    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()
 
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    overviewCard
                    insightsSection
                    overviewSection
                    accountSummaryCard
                }
                .padding(20)
            }
        }
        .task {
            model.prepareData()
        }
    }
 
    // MARK: - Overview
 
    private var overviewCard: some View {
        VStack(spacing: 15) {
            Text(model.homeViewData?.headerTitle ?? " ")
                .font(.manrope, size: 20, weight: .bold)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
 
            HStack(spacing: 10) {
                ForEach(SummaryType.allCases, id: \.self) { type in
                    SummaryCard(type: type, amount: amountText(for: type))
                }
            }
        }
    }
 
    private func amountText(for type: SummaryType) -> String {
        guard let insights = model.homeViewData?.insights else { return "—" }
        return TakaFormatter.string(insights.amount(for: type))
    }
 
    // MARK: - Insights
 
    @ViewBuilder
    private var insightsSection: some View {
        if let insights = model.homeViewData?.insights {
            VStack(spacing: 16) {
                SectionHeader(title: "Insights") {
                    Text("This month")
                        .font(.manrope, size: 13, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.fillSubtle, in: Capsule())
                }
 
                InsightsCard(insights: insights)
            }
        }
    }
 
    // MARK: - Net worth

    @ViewBuilder
    private var overviewSection: some View {
        if let overview = model.homeViewData?.overview {
            VStack(spacing: 16) {
                SectionHeader(title: "Summary") { EmptyView() }
                FinanceOverviewCard(overview: overview)
            }
        }
    }

    // MARK: - Accounts
 
    private var accountSummaryCard: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Accounts") { EmptyView() }

            HomeAccountGrid(accounts: model.homeViewData?.accounts ?? [])
        }
    }

}

private struct HomeAccountGrid: View {
    let accounts: [Account]

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        // No nested ScrollView: the outer one scrolls, so the grid stays lazy.
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(accounts) { account in
                AccountCard(account: account)
                    .shadow(color: Color(hex: account.tint).opacity(0.35), radius: 10, x: 0, y: 0)
            }
        }
    }
}
 
// MARK: - Reusable section header
 
private struct SectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing
 
    var body: some View {
        HStack {
            Text(title)
                .font(.manrope, size: 20, weight: .bold)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            trailing
        }
    }
}
 
#Preview {
    HomeView(model: HomeViewModel())
}
