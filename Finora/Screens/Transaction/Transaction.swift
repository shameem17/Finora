//
//  Transaction.swift
//  Finora
//
//  Screens/Transaction/View
//

import SwiftUI

struct TransactionView<ViewModel: TransactionViewModelProtocol>: View {

    @Bindable var model: ViewModel
    @State private var form: TransferFormViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PillPicker(selection: $model.period)
                        TransferSummaryCard(period: model.period, summary: model.summary)
                        history
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: model.period)
                }
            }
            .safeAreaInset(edge: .bottom) { addButton }
        }
        .task { model.load() }
        .sheet(item: $form) { TransferFormView(form: $0) }
    }

    // MARK: - Pieces

    @ViewBuilder
    private var history: some View {
        if model.sections.isEmpty {
            EmptyTransfersView(period: model.period)
        } else {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(model.sections) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.title)
                            .font(.manrope, size: 16, weight: .bold)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            ForEach(section.transfers) { transfer in
                                TransferRow(transfer: transfer)
                                if transfer.id != section.transfers.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .finoraCard(cornerRadius: 24)
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            form = model.makeFormViewModel()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.left.arrow.right")
                Text("New Transfer")
            }
            .font(.manrope, size: 20, weight: .extraBold)
            .foregroundStyle(Color.textPrimary)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(CustomColor.warmCoral.color)
            .clipShape(Capsule())
            .shadow(color: CustomColor.warmCoral.color.opacity(0.4), radius: 12, y: 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    TransactionView(model: TransactionViewModel(
        accountRepository: InMemoryAccountRepository(),
        transferRepository: InMemoryTransferRepository()
    ))
}
