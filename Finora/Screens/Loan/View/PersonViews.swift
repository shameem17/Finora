//
//  PersonViews.swift
//  Finora
//
//  Screens/Loan/View
//
//  People management: list, add / edit form, and the picker used by the loan form.
//

import SwiftUI

// MARK: - People list

struct PeopleView<ViewModel: PeopleViewModelProtocol>: View {

    @Bindable var model: ViewModel
    @State private var form: PersonFormViewModel?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if !model.isEmpty {
                        SearchField(text: $model.searchText, prompt: "Search by name or number")
                    }
                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("People")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: "Add Person") {
                form = model.makeFormViewModel(editing: nil)
            }
        }
        .task { model.load() }
        .sheet(item: $form) { PersonFormView(form: $0) }
    }

    @ViewBuilder
    private var content: some View {
        let rows = model.rows
        if rows.isEmpty {
            PeopleEmptyState(isSearching: !model.isEmpty)
        } else {
            VStack(spacing: 0) {
                ForEach(rows) { row in
                    Button {
                        form = model.makeFormViewModel(editing: row.person)
                    } label: {
                        PersonRow(row: row)
                    }
                    .buttonStyle(.plain)

                    if row.id != rows.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .finoraCard(cornerRadius: 24)
        }
    }
}

private struct PersonRow: View {
    let row: PersonRowData

    private var person: Person { row.person }

    private var subtitle: String {
        if let phone = person.phone, !phone.isEmpty { return phone }
        return person.category.title
    }

    var body: some View {
        HStack(spacing: 14) {
            PersonAvatar(person: person, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                if abs(row.netBalance) < Loan.tolerance {
                    Text(row.totalCount == 0 ? "No entries" : "Settled")
                        .font(.manrope, size: 13, weight: .semiBold)
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text(CurrencyFormatter.taka(abs(row.netBalance), showFraction: true))
                        .font(.manrope, size: 15, weight: .extraBold)
                        .foregroundStyle(row.netBalance > 0
                                         ? Color.positive
                                         : Color.negative)
                    Text(row.netBalance > 0 ? "owes you" : "you owe")
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

private struct PeopleEmptyState: View {
    let isSearching: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isSearching ? "magnifyingglass" : "person.2")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.textTertiary)

            Text(isSearching ? "No matches" : "No people yet")
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Text(isSearching
                 ? "Try a different name or number."
                 : "Add friends, family, banks or wallets here so you can pick them quickly when you lend or borrow.")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}

// MARK: - Person form

struct PersonFormView: View {

    @Bindable var form: PersonFormViewModel
    /// `true` when pushed inside another NavigationStack (e.g. the person picker);
    /// `false` when presented as its own sheet.
    var isEmbedded = false

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?
    @State private var confirmDelete = false

    private enum Field: Hashable { case name, phone, address }

    private let categoryColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        if isEmbedded {
            content
        } else {
            NavigationStack { content }
                .presentationDragIndicator(.visible)
        }
    }

    private var content: some View {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        identityCard
                        contactCard
                        FormErrorBanner(message: form.duplicateError)
                        deleteSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: form.duplicateError)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(form.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isEmbedded {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .font(.manrope, size: 16, weight: .semiBold)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = nil }
                }
            }
            .safeAreaInset(edge: .bottom) {
                FormPrimaryButton(title: "Save Person", isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
            }
            .confirmationDialog("Delete this person?",
                                isPresented: $confirmDelete,
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if form.delete() { dismiss() }
                }
            } message: {
                Text("They'll be removed from your people list.")
            }
    }

    // MARK: Cards

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NAME")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(Color.textSecondary)

            TextField("e.g. Rahim Uddin", text: $form.name)
                .font(.manrope, size: 22, weight: .extraBold)
                .foregroundStyle(Color.textPrimary)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .focused($focused, equals: .name)
                .onSubmit { focused = .phone }

            Divider()

            Text("TYPE")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(Color.textSecondary)

            LazyVGrid(columns: categoryColumns, spacing: 10) {
                ForEach(PersonCategory.allCases) { category in
                    categoryChip(category)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .name }
    }

    private func categoryChip(_ category: PersonCategory) -> some View {
        let isSelected = form.category == category
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                form.category = category
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 13, weight: .bold))
                Text(category.title)
                    .font(.manrope, size: 14, weight: .bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? Color.cardSurface : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Capsule().fill(isSelected ? Color.textPrimary : Color.fillSubtle)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var contactCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "phone.fill", title: "Contact no. (optional)") {
                TextField("01XXXXXXXXX", text: $form.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .multilineTextAlignment(.trailing)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focused, equals: .phone)
                    .frame(maxWidth: 170)
                    .onChange(of: form.phone) { _, new in
                        let clean = PhoneInput.sanitize(new)
                        if clean != new { form.phone = clean }
                    }
            }

            Divider()

            FormFieldRow(icon: "mappin.and.ellipse", title: "Address (optional)", alignTop: true) {
                TextField("Area, city…", text: $form.address, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(Color.textPrimary)
                    .textContentType(.fullStreetAddress)
                    .focused($focused, equals: .address)
                    .submitLabel(.done)
                    .onSubmit { focused = nil }
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    @ViewBuilder
    private var deleteSection: some View {
        if form.isEditing {
            VStack(spacing: 8) {
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label("Delete Person", systemImage: "trash")
                        .font(.manrope, size: 15, weight: .bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(Color.negative)
                        .background(Color.negative.opacity(0.1), in: Capsule())
                }
                .disabled(!form.canDelete)
                .opacity(form.canDelete ? 1 : 0.45)

                if let reason = form.deleteBlockedReason {
                    Text(reason)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Picker (used by the loan form)

struct PersonPickerView: View {

    @Bindable var form: LoanFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var newPerson: PersonFormViewModel?

    private var filtered: [Person] {
        let needle = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return form.people }
        return form.people.filter { $0.name.localizedCaseInsensitiveContains(needle) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if !form.people.isEmpty {
                            SearchField(text: $search, prompt: "Search")
                        }
                        newPersonButton
                        list
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Select \(form.kind.personRole)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.manrope, size: 16, weight: .semiBold)
                }
            }
            // Pushed (not a second sheet): stacked sheets are where SwiftUI loses dismissals.
            .navigationDestination(item: $newPerson) { PersonFormView(form: $0, isEmbedded: true) }
        }
        .presentationDragIndicator(.visible)
        // A newly created person is selected by the form view model; close the picker with it.
        .onChange(of: form.personID) { _, _ in dismiss() }
    }

    private var newPersonButton: some View {
        Button {
            newPerson = form.makePersonFormViewModel()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 46, height: 46)
                    .background(Color.accent, in: Circle())

                Text("Add new person")
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()
            }
            .padding(14)
            .contentShape(Rectangle())
            .finoraCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var list: some View {
        let people = filtered
        if !people.isEmpty {
            VStack(spacing: 0) {
                ForEach(people) { person in
                    Button {
                        form.personID = person.id
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            PersonAvatar(person: person, size: 46)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(person.name)
                                    .font(.manrope, size: 15, weight: .bold)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)

                                Text(person.phone ?? person.category.title)
                                    .font(.manrope, size: 12, weight: .medium)
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 8)

                            if person.id == form.personID {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.positive)
                            }
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if person.id != people.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .finoraCard(cornerRadius: 24)
        } else if !form.people.isEmpty {
            Text("No one matches “\(search)”.")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 8)
        }
    }
}

#Preview("People") {
    NavigationStack {
        PeopleView(model: PeopleViewModel(dependencies: .preview()))
    }
}

#Preview("Person form") {
    PersonFormView(form: PersonFormViewModel(mode: .create,
                                             repository: InMemoryPersonRepository()))
}
