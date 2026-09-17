import SwiftUI

struct ReciterPickerView: View {
    let viewModel: SettingsViewModel
    
    @Environment(PreferencesStore.self) private var preferences
    @Environment(AudioPlayerManager.self) private var audioPlayer
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedIdentifier: String?
    
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
                                    if preferences.selectedReciter != edition.identifier {
                                        preferences.selectedReciter = edition.identifier
                                        audioPlayer.stop()
                                    }
                                    dismiss()
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
            }
        }
        .onAppear {
            focusedIdentifier = preferences.selectedReciter
        }
    }
}
