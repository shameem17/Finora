//
//  Settings.swift
//  Finora
//
//  Screens/Settings
//
//  Hosted by SettingsCoordinator inside its UINavigationController, so there is
//  no NavigationStack here: the title bridges to the UIKit bar.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.appSettings) private var settings
    @State private var showsPrivacyPolicy = false

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    group("Preferences") {
                        toggleRow(icon: "bell",
                                  title: "Loan reminders",
                                  subtitle: "Local notifications for due dates",
                                  isOn: $settings.notificationsEnabled)
                        divider
                        infoRow(icon: "banknote", title: "Currency", value: "\(settings.currency.symbol) \(settings.currency.rawValue.uppercased())")
                    }

                    group("Privacy") {
                        Button { showsPrivacyPolicy = true } label: {
                            row(icon: "lock.shield", title: "Privacy Policy",
                                subtitle: "How Finora handles your data") {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.textTertiary)
                            }
                        }
                        .buttonStyle(.plain)

                        divider
                        infoRow(icon: "iphone", title: "Storage", value: "On this device only")
                    }

                    group("About") {
                        infoRow(icon: "info.circle", title: "Version", value: version)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showsPrivacyPolicy) {
            NavigationStack {
                PrivacyPolicyView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showsPrivacyPolicy = false }
                                .font(.manrope, size: 16, weight: .semiBold)
                        }
                    }
            }
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Building blocks

    private var divider: some View {
        Divider().overlay(Color.hairline).padding(.leading, 52)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title).padding(.horizontal, 4)
            VStack(spacing: 0) { content() }
                .sectionCard(padding: 6)
        }
    }

    private func row<Trailing: View>(icon: String,
                                     title: String,
                                     subtitle: String? = nil,
                                     @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.onAccent)
                .frame(width: 32, height: 32)
                .background(Color.accent, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle {
                    Text(subtitle)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            Spacer(minLength: 8)
            trailing()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        row(icon: icon, title: title, subtitle: subtitle) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.brandSecondary)
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        row(icon: icon, title: title) {
            Text(value)
                .font(.manrope, size: 14, weight: .semiBold)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
