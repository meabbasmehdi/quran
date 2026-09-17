import SwiftUI

struct ReciterStepView: View {
    var viewModel: OnboardingViewModel
    @FocusState.Binding var focusTarget: FocusTarget?
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Choose Your Reciter")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Select a Quran reciter for audio playback")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Group {
                switch viewModel.reciters {
                case .idle, .loading:
                    LoadingView()
                case .empty(let message):
                    EmptyStateView(icon: "person.wave.2", message: message)
                case .error(let error):
                    ErrorStateView(message: error.localizedDescription) {
                        Task { await viewModel.loadData() }
                    }
                case .content(let editions):
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(Array(editions.enumerated()), id: \.element.id) { index, edition in
                                Button {
                                    viewModel.selectedReciter = edition.identifier
                                } label: {
                                    ReciterRow(
                                        edition: edition,
                                        isSelected: viewModel.selectedReciter == edition.identifier,
                                        isFocused: focusTarget == .onboardingItem(index)
                                    )
                                }
                                .buttonStyle(QuranButtonStyle())
                                .focused($focusTarget, equals: .onboardingItem(index))
                                .quranFocusStyle(
                                    isFocused: focusTarget == .onboardingItem(index),
                                    cornerRadius: AppRadius.medium
                                )
                            }
                        }
                        .padding(.horizontal, 100)
                        .padding(.vertical, AppSpacing.md)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct ReciterRow: View {
    let edition: Edition
    let isSelected: Bool
    let isFocused: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(edition.englishName)
                    .font(AppTypography.headline)
                    .foregroundColor(isFocused ? .white : AppColors.textPrimary)
                
                Text(edition.name)
                    .font(AppTypography.caption)
                    .foregroundColor(isFocused ? .white.opacity(0.8) : AppColors.textSecondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(isFocused ? .white : AppColors.accent)
                    .font(.title2)
            }
        }
        .padding(AppSpacing.lg)
        .background(isFocused ? AppColors.accent : AppColors.surface)
        .cornerRadius(AppRadius.medium)
    }
}
