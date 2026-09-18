import SwiftUI

struct ReciterPickerView: View {
    let viewModel: SettingsViewModel

    @Environment(PreferencesStore.self) private var preferences
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedIdentifier: String?

    @State private var isSavingSelection = false

    var body: some View {
        Group {
            switch viewModel.reciters {
            case .idle, .loading:
                LoadingView()
            case .empty(let message):
                EmptyStateView(icon: "speaker.slash", message: message)
            case .error(let error):
                ErrorStateView(message: error.localizedDescription) {
                    Task { await viewModel.loadEditions() }
                }
            case .content(let editions):
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Select Reciter")
                            .font(AppTypography.headline)
                            .padding(.bottom, AppSpacing.md)

                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(editions) { edition in
                                Button {
                                    selectReciter(identifier: edition.identifier)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(edition.englishName)
                                                .font(AppTypography.body)
                                            Text(edition.name)
                                                .font(AppTypography.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                        Spacer()
                                        if preferences.selectedReciter == edition.identifier {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(AppColors.accent)
                                        }
                                    }
                                    .padding(AppSpacing.md)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                                }
                                .buttonStyle(QuranButtonStyle())
                                .focused($focusedIdentifier, equals: edition.identifier)
                                .quranFocusStyle(
                                    isFocused: focusedIdentifier == edition.identifier,
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

                    guard focusedIdentifier == nil else { return }

                    let selectedIdentifier = preferences.selectedReciter
                    if editions.contains(where: { $0.identifier == selectedIdentifier }) {
                        focusedIdentifier = selectedIdentifier
                    } else {
                        focusedIdentifier = editions.first?.identifier
                    }
                }
            }
        }
    }

    @MainActor
    private func selectReciter(identifier: String) {
        guard !isSavingSelection else { return }
        isSavingSelection = true

        if preferences.selectedReciter != identifier {
            preferences.selectedReciter = identifier
        }

        // Keep focus/checkmark synchronized with the saved value.
        focusedIdentifier = identifier

        Task { @MainActor in
            // Give SwiftUI a chance to process the preference change before
            // dismissing the picker so the parent row and checkmark update.
            await Task.yield()
            dismiss()
        }
    }
}
