import SwiftUI

struct SurahRowView: View {
    let surah: Surah
    let isFocused: Bool
    @Environment(PreferencesStore.self) private var preferences
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: AppSpacing.md) {
                // Number Badge
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Text("\(surah.number)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.accent)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(surah.englishName)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(surah.englishTranslation) • \(surah.ayahCount) Ayahs • \(surah.revelationType.rawValue)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(surah.arabicName)
                    .font(AppTypography.arabicFont(size: 30, name: preferences.arabicFontName))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(isFocused ? AppColors.surfaceElevated : Color.clear)
            .cornerRadius(AppRadius.medium)
        }
        .buttonStyle(QuranButtonStyle())
        .quranFocusStyle(isFocused: isFocused, cornerRadius: AppRadius.medium)
    }
}
