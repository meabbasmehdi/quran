import SwiftUI

struct FontSettingsStepView: View {
    var viewModel: OnboardingViewModel
    @FocusState.Binding var focusTarget: FocusTarget?
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Arabic Text Settings")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Adjust the Arabic text to your preference")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()

            HStack(spacing: AppSpacing.md) {
                ForEach(ArabicFontChoice.allCases) { choice in
                    Button {
                        viewModel.arabicFontName = choice.rawValue
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            Text("بِسْمِ اللَّهِ")
                                .font(AppTypography.arabicFont(size: 26, name: choice.rawValue))
                            Text(choice.title)
                                .font(AppTypography.caption)
                        }
                        .frame(width: 190, height: 90)
                    }
                    .buttonStyle(QuranButtonStyle())
                    .background(viewModel.arabicFontName == choice.rawValue ? AppColors.accent.opacity(0.2) : AppColors.surface)
                    .cornerRadius(AppRadius.medium)
                    .focused($focusTarget, equals: .onboardingFontOption(choice.rawValue))
                    .quranFocusStyle(
                        isFocused: focusTarget == .onboardingFontOption(choice.rawValue),
                        cornerRadius: AppRadius.medium
                    )
                }
            }
            
            HStack(spacing: AppSpacing.xxl) {
                Button(action: {
                    if viewModel.fontSize > 22 {
                        viewModel.fontSize -= 2
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.title)
                        .frame(width: 80, height: 80)
                }
                .buttonStyle(QuranButtonStyle())
                .background(focusTarget == .onboardingFontDecrease ? AppColors.accent : AppColors.surfaceElevated)
                .foregroundColor(AppColors.textPrimary)
                .cornerRadius(40)
                .focused($focusTarget, equals: .onboardingFontDecrease)
                .quranFocusStyle(isFocused: focusTarget == .onboardingFontDecrease, cornerRadius: 40)
                .disabled(viewModel.fontSize <= 22)
                
                Text("\(Int(viewModel.fontSize))")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 100)
                
                Button(action: {
                    if viewModel.fontSize < 50 {
                        viewModel.fontSize += 2
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .frame(width: 80, height: 80)
                }
                .buttonStyle(QuranButtonStyle())
                .background(focusTarget == .onboardingFontIncrease ? AppColors.accent : AppColors.surfaceElevated)
                .foregroundColor(AppColors.textPrimary)
                .cornerRadius(40)
                .focused($focusTarget, equals: .onboardingFontIncrease)
                .quranFocusStyle(isFocused: focusTarget == .onboardingFontIncrease, cornerRadius: 40)
                .disabled(viewModel.fontSize >= 50)
            }
            
            Spacer()
            
            AppCard {
                AyahTextView(
                    arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                    fontSize: viewModel.fontSize,
                    fontName: viewModel.arabicFontName
                )
                .padding(AppSpacing.xl)
                .frame(maxWidth: 800, minHeight: 200)
            }
            
            Spacer()
        }
    }
}
