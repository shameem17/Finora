import SwiftUI

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    let model: ViewModel
    
    private let rows: [GridItem] = [
        GridItem(.flexible(), spacing: 10)
    ]
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    
    @State private var hideBalances = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    overviewCard
                    
                    accountSummaryCard
                    
                    summaryCard
                    
                    
                }
            }
            .padding(20)
        }
        .padding(.horizontal)
        .task {
            model.prepareData()
        }
    }
    
    var overviewCard: some View {
        VStack(spacing: 15) {
            Text(model.homeViewData?.headerTitle ?? "")
                .font(.manrope, size: 20, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyHGrid(rows: rows, spacing: 10) {
                ForEach(SummaryType.allCases, id: \.self) { type in
                    SummaryCard(type: type)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    var summaryCard: some View {
        VStack{
            Text("Summary")
            
            IncomeDonutCard()
            
        }
    }
    
    var accountSummaryCard: some View {
        VStack{
            HStack{
                Text("Accounts")
                    .font(.manrope, size: 20, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color)
                Spacer()
                Button {
                    withAnimation { hideBalances.toggle() }
                } label: {
                    Image(systemName: hideBalances ? "eye.slash" : "eye")
                        .resizable()
                        .frame(width: 30, height: 20)
                        .foregroundColor(CustomColor.darkGray.color)
                }
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(model.homeViewData?.accounts ?? []) { account in
                        AccountCard(account: account, hideBalance: hideBalances)
                            .shadow(color: Color(hex: account.tint).opacity(0.35), radius: 10, x: 0, y: 0)
                    }
                }
            }
        }
        
    }
}



#Preview {
    HomeView(model: HomeViewModel())
}


