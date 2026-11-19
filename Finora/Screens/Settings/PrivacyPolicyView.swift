//
//  PrivacyPolicyView.swift
//  Finora
//
//  Screens/Settings
//
//  The policy text is plain data (`PrivacyPolicy`) so it can be reviewed and
//  edited without touching any layout code.
//

import SwiftUI

// MARK: - Content

struct PrivacyPolicy {

    struct Section: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let paragraphs: [String]
        var bullets: [String] = []
    }

    let effectiveDate: String
    let summary: String
    let sections: [Section]

    static let current = PrivacyPolicy(
        effectiveDate: "November 19, 2026",
        summary: "Finora keeps everything on your device. There is no account, no server and no tracking. We cannot see your data, because it never leaves your phone.",
        sections: [
            Section(
                icon: "iphone",
                title: "Your data stays on your device",
                paragraphs: [
                    "Finora works fully offline. The information you enter is stored only in the app's private storage on your iPhone and is never sent to us or to anyone else.",
                    "Finora does not require you to sign up or log in, and it has no backend server."
                ]
            ),
            Section(
                icon: "list.bullet.rectangle",
                title: "Information you enter",
                paragraphs: ["To track your finances, you may add the following to the app:"],
                bullets: [
                    "Accounts: names, account or card numbers you choose to type, account type, colour, logo and balances (bank, mobile wallet, card, cash and similar).",
                    "Income, expenses and transfers between your accounts, including amounts, dates, categories and notes.",
                    "Loans you have lent or borrowed, repayments, due dates, and the names (and any notes) of the people involved.",
                    "Savings goals, deposits, withdrawals and targets.",
                    "Categories and monthly budgets you create."
                ]
            ),
            Section(
                icon: "person.2",
                title: "Information about other people",
                paragraphs: [
                    "If you record a loan, you may type another person's name or a note about them. That information is stored only on your device, together with the rest of your data, and is used only to show you your own records. Please enter only what you are comfortable keeping."
                ]
            ),
            Section(
                icon: "photo",
                title: "Photos",
                paragraphs: [
                    "You can pick an image as an account logo. Finora uses the system photo picker, so the app can only see the single image you choose, not your photo library. The chosen image is stored in the app as a small copy and is never uploaded."
                ]
            ),
            Section(
                icon: "bell",
                title: "Notifications",
                paragraphs: [
                    "If you allow notifications, Finora schedules local reminders for loan due dates. These are created and delivered by iOS on your device; no push-notification service or server is involved. You can turn reminders off in Settings or in iOS Settings at any time."
                ]
            ),
            Section(
                icon: "hand.raised",
                title: "What we do not do",
                paragraphs: [],
                bullets: [
                    "We do not collect, transmit, sell or share your personal or financial data.",
                    "We do not use analytics, advertising, tracking or crash-reporting services.",
                    "We do not include third-party SDKs that collect data.",
                    "We do not connect to your bank or read your messages, contacts or location."
                ]
            ),
            Section(
                icon: "lock.shield",
                title: "Security",
                paragraphs: [
                    "Your data lives inside the app's sandbox, which other apps cannot read, and is protected by the same device encryption that protects the rest of your iPhone. Set a strong passcode and keep your device updated to protect it.",
                    "Hide-balances mode masks amounts on screen, but it is a privacy convenience and not a lock."
                ]
            ),
            Section(
                icon: "icloud",
                title: "Backups",
                paragraphs: [
                    "Finora does not sync to iCloud and has no cloud features of its own. However, if you back up your iPhone with iCloud or to a computer, iOS may include the app's data in that backup. Backups are controlled by you and by Apple, and are covered by Apple's own privacy terms."
                ]
            ),
            Section(
                icon: "trash",
                title: "Your control and deleting data",
                paragraphs: [
                    "You can edit or delete any account, entry, loan, person, savings goal or category inside the app. Deleting the app removes all of its data from your device. Because we hold no copy, we cannot recover data after it is deleted, so keep a device backup if it matters to you."
                ]
            ),
            Section(
                icon: "figure.and.child.holdinghands",
                title: "Children",
                paragraphs: [
                    "Finora is a general personal-finance tool and is not directed at children under 13. We do not knowingly collect information from anyone, including children."
                ]
            ),
            Section(
                icon: "exclamationmark.circle",
                title: "Not financial advice",
                paragraphs: [
                    "Finora helps you record and view your own figures. Totals, insights and summaries are calculated from what you enter and are not financial, tax or legal advice. Keep your own records for anything official."
                ]
            ),
            Section(
                icon: "arrow.triangle.2.circlepath",
                title: "Changes to this policy",
                paragraphs: [
                    "If the app's features change in a way that affects privacy, for example by adding optional sync, we will update this policy and the effective date above before the change ships."
                ]
            ),
            Section(
                icon: "envelope",
                title: "Contact",
                paragraphs: [
                    "For questions about this policy, use the support contact on Finora's App Store page."
                ]
            )
        ]
    )
}

// MARK: - View

struct PrivacyPolicyView: View {

    let policy: PrivacyPolicy

    init(policy: PrivacyPolicy = .current) {
        self.policy = policy
    }

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    hero
                    ForEach(policy.sections) { section in
                        sectionCard(section)
                    }
                    Text("Effective \(policy.effectiveDate)")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.accent)

            Text("Private by design")
                .font(.manrope, size: 22, weight: .extraBold)
                .foregroundStyle(Color.onHero)

            Text(policy.summary)
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.onHeroSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .heroCard()
    }

    private func sectionCard(_ section: PrivacyPolicy.Section) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.onAccent)
                    .frame(width: 28, height: 28)
                    .background(Color.accent, in: Circle())

                Text(section.title)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(section.paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.manrope, size: 14, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(section.bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Text(bullet)
                        .font(.manrope, size: 14, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .sectionCard()
    }
}

#Preview {
    NavigationStack { PrivacyPolicyView() }
}
