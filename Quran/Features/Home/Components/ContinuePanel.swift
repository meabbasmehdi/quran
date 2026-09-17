import SwiftUI

struct ContinuePanel: View {
    let selectedSurah: Surah?
    let selectedJuz: Int?
    let activeTab: HomeTab
    
    @Environment(ReadingStateStore.self) private var readingState
    @Environment(PlaybackStateStore.self) private var playbackState
    @Environment(AppRouter.self) private var router
    @Environment(PreferencesStore.self) private var preferences
    @FocusState.Binding var focusTarget: FocusTarget?
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            if readingState.hasReadingState {
                AppCard {
                    Button {
                        router.navigateToReader(source: .surah(readingState.lastSurahNumber ?? 1))
                    } label: {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Continue Reading")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.accent)
                            
                            Text("Surah \(readingState.lastSurahNumber ?? 1), Ayah \(readingState.lastAyahNumber ?? 1)")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(QuranButtonStyle())
                    .focused($focusTarget, equals: .continueReading)
                    .quranFocusStyle(
                        isFocused: focusTarget == .continueReading,
                        cornerRadius: AppRadius.card
                    )
                }
            }
            
            if playbackState.hasPlaybackState {
                AppCard {
                    Button {
                        router.navigateToReader(source: .surah(playbackState.surahNumber ?? 1))
                    } label: {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Continue Listening")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.accent)
                            
                            Text("Surah \(playbackState.surahNumber ?? 1)")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(QuranButtonStyle())
                    .focused($focusTarget, equals: .continueListening)
                    .quranFocusStyle(
                        isFocused: focusTarget == .continueListening,
                        cornerRadius: AppRadius.card
                    )
                }
            }
            
            Spacer()
            
            // Info Section
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if activeTab == .surah, let surah = selectedSurah {
                    Text(surah.arabicName)
                        .font(AppTypography.arabicFont(size: 36, name: preferences.arabicFontName))
                        .foregroundColor(AppColors.textPrimary)
                    Text(surah.englishName)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(surah.englishTranslation) • \(surah.ayahCount) Ayahs")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                    Text(surah.revelationType.rawValue)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                } else if activeTab == .juz, let juz = selectedJuz {
                    Text("Juz \(juz)")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    if let juzData = JuzListView.juzStartingSurahs.first(where: { $0.juz == juz }) {
                        Text("Starts with \(juzData.surah)")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, AppSpacing.xl)
    }
}
