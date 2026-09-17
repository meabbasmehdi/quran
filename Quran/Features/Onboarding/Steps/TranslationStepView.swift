import SwiftUI

struct TranslationStepView: View {
    var viewModel: OnboardingViewModel
    @FocusState.Binding var focusTarget: FocusTarget?
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Choose Your Translation")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Select a translation to display alongside the Arabic text")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Group {
                switch viewModel.translations {
                case .idle, .loading:
                    LoadingView()
                case .empty(let message):
                    EmptyStateView(icon: "text.book.closed", message: message)
                case .error(let error):
                    ErrorStateView(message: error.localizedDescription) {
                        Task { await viewModel.loadData() }
                    }
                case .content(let editions):
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(Array(editions.enumerated()), id: \.element.id) { index, edition in
                                Button {
                                    viewModel.selectedTranslation = edition.identifier
                                } label: {
                                    TranslationRow(
                                        edition: edition,
                                        isSelected: viewModel.selectedTranslation == edition.identifier,
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
            
            // Live Preview
            AppCard {
                VStack(spacing: AppSpacing.md) {
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(AppTypography.arabicFont(size: 36, name: viewModel.arabicFontName))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let selected = selectedEdition() {
                        Text("In the name of Allah, the Entirely Merciful, the Especially Merciful.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text(selected.englishName)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.accent)
                    }
                }
                .padding(AppSpacing.xl)
                .frame(maxWidth: 800)
            }
        }
    }
    
    private func selectedEdition() -> Edition? {
        guard case .content(let editions) = viewModel.translations else { return nil }
        return editions.first { $0.identifier == viewModel.selectedTranslation }
    }
}

struct TranslationRow: View {
    let edition: Edition
    let isSelected: Bool
    let isFocused: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(edition.englishName)
                    .font(AppTypography.headline)
                    .foregroundColor(isFocused ? .white : AppColors.textPrimary)
                
                Text(edition.language.uppercased())
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
