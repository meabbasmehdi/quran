import SwiftUI

struct SurahHeaderView: View {
    let surah: Surah
    let isJuzMode: Bool
    let juzNumber: Int?
    let arabicFontName: String
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            if isJuzMode, let juz = juzNumber {
                Text("Juz \(juz)")
                    .font(.headline)
                    .foregroundColor(AppColors.accent)
            }
            
            Text(surah.arabicName)
                .font(AppTypography.arabicFont(size: 56, name: arabicFontName))
                .foregroundColor(AppColors.textPrimary)
            
            Text("\(surah.englishName) • \(surah.englishTranslation)")
                .font(.title3)
                .foregroundColor(AppColors.textSecondary)
            
            Text(String(surah.ayahCount) + " Ayahs • " + surah.revelationType.rawValue)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom, AppSpacing.sm)
            
            Divider()
                .background(AppColors.divider)
                .padding(.top, AppSpacing.md)
        }
        .padding(.vertical, AppSpacing.md)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
