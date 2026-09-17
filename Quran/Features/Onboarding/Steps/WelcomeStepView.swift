import SwiftUI

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Image(systemName: "book.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .foregroundColor(AppColors.accent)
            
            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                .font(AppTypography.arabicDisplay)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Quran")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.accent)
                
                Text("Your personal Quran companion for Apple TV")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}
