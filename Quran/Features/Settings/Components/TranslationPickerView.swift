import SwiftUI

struct TranslationPickerView: View {

    let viewModel: SettingsViewModel

    @Environment(PreferencesStore.self) private var preferences
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedIdentifier: String?

    @State private var isSavingSelection = false

    var body: some View {
        Group {
            switch viewModel.translations {

            case .idle, .loading:
                LoadingView()

            case .empty(let message):
                EmptyStateView(
                    icon: "text.book.closed",
                    message: message
                )

            case .error(let error):
                ErrorStateView(
                    message: error.localizedDescription
                ) {
                    Task {
                        await viewModel.loadEditions()
                    }
                }

            case .content(let editions):
                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: AppSpacing.md
                    ) {
                        Text("Select Translation")
                            .font(AppTypography.headline)
                            .padding(.bottom, AppSpacing.md)

                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(editions) { edition in
                                Button {
                                    selectTranslation(
                                        identifier: edition.identifier
                                    )
                                } label: {
                                    HStack {
                                        VStack(
                                            alignment: .leading,
                                            spacing: AppSpacing.xs
                                        ) {
                                            Text(edition.englishName)
                                                .font(AppTypography.body)

                                            Text(
                                                edition.language.uppercased()
                                            )
                                            .font(AppTypography.caption)
                                            .foregroundStyle(
                                                AppColors.textSecondary
                                            )
                                        }

                                        Spacer()

                                        if preferences.selectedTranslation ==
                                            edition.identifier {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(
                                                    AppColors.accent
                                                )
                                        }
                                    }
                                    .padding(AppSpacing.md)
                                    .background(AppColors.surface)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: AppRadius.medium
                                        )
                                    )
                                }
                                .buttonStyle(QuranButtonStyle())

                                // Do NOT add .focusable(true) here.
                                // Button already participates in tvOS focus.
                                .focused(
                                    $focusedIdentifier,
                                    equals: edition.identifier
                                )

                                .quranFocusStyle(
                                    isFocused:
                                        focusedIdentifier ==
                                        edition.identifier,
                                    cornerRadius: AppRadius.medium
                                )
                            }
                        }
                        .focusSection()
                    }
                    .padding(AppSpacing.xl)
                }
                .task(id: editions.map(\.identifier)) {
                    await Task.yield()

                    guard focusedIdentifier == nil else {
                        return
                    }

                    let selectedIdentifier =
                        preferences.selectedTranslation

                    if editions.contains(where: {
                        $0.identifier == selectedIdentifier
                    }) {
                        focusedIdentifier = selectedIdentifier
                    } else {
                        focusedIdentifier =
                            editions.first?.identifier
                    }
                }
            }
        }
    }

    @MainActor
    private func selectTranslation(identifier: String) {
        guard !isSavingSelection else {
            return
        }

        isSavingSelection = true

        // Existing model/store remains the single source of truth.
        preferences.selectedTranslation = identifier

        // Only continue once the store reflects the new selection.
        guard preferences.selectedTranslation == identifier else {
            isSavingSelection = false
            return
        }

        // Keep focus/checkmark synchronized with the saved value.
        focusedIdentifier = identifier

        Task { @MainActor in
            // Give SwiftUI a chance to process the preference change
            // before dismissing the picker.
            await Task.yield()
            dismiss()
        }
    }
}
