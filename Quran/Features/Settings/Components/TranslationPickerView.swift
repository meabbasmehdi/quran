import SwiftUI

struct TranslationPickerView: View {
    let viewModel: SettingsViewModel
    
    @Environment(PreferencesStore.self) private var preferences
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedIdentifier: String?
    
    var body: some View {
        Group {
            switch viewModel.translations {
            case .idle, .loading:
                LoadingView()
            case .empty(let message):
                EmptyStateView(icon: "text.book.closed", message: message)
            case .error(let error):
                ErrorStateView(message: error.localizedDescription) {
                    Task { await viewModel.loadEditions() }
                }
            case .content(let editions):
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Select Translation")
                            .font(AppTypography.headline)
                            .padding(.bottom, AppSpacing.md)
                        
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(editions) { edition in
                                Button {
                                    preferences.selectedTranslation = edition.identifier
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(edition.englishName)
                                                .font(AppTypography.body)
                                            Text(edition.language.uppercased())
                                                .font(AppTypography.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                        Spacer()
                                        if preferences.selectedTranslation == edition.identifier {
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
            }
        }
        .onAppear {
            focusedIdentifier = preferences.selectedTranslation
        }
    }
}
