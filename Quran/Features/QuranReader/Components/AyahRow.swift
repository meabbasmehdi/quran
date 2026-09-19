import SwiftUI

struct AyahRow: View {
    let ayah: Ayah
    let displayState: AyahDisplayState
    let preferences: PreferencesStore
    let action: () -> Void
    
    @Environment(\.isFocused) private var isFocused
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .trailing, spacing: 0) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    // Ayah Badge
                    ZStack {
                        Circle()
                            .stroke(AppColors.accent, lineWidth: 2)
                            .frame(width: 40, height: 40)

                        Text(formatAyahNumber(ayah.numberInSurah))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.accent)
                    }
                    .padding(.top, 8)

                    // Arabic Text
                    Text(displayArabicText)
                        .font(AppTypography.arabicFont(size: preferences.fontSize, name: preferences.arabicFontName))
                        .foregroundColor(AppColors.textPrimary)
                        .lineSpacing(preferences.fontSize * 0.5)
                        .lineLimit(nil)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                        .environment(\.layoutDirection, .rightToLeft)
                }

                // Translation Text
                if let translation = ayah.translationText {
                    Text(translation)
                        .font(.system(size: preferences.fontSize * 0.5))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(6)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .environment(\.layoutDirection, .leftToRight)
                        .padding(.top, AppSpacing.lg)
                        .padding(.leading, 56) // Account for the badge width + spacing
                }

                Divider()
                    .background(AppColors.divider)
                    .padding(.top, AppSpacing.lg)
            }
            .padding(AppSpacing.lg)
            .background(backgroundView)
        }
        .buttonStyle(QuranButtonStyle())
        .quranFocusStyle(isFocused: isFocused)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch displayState {
        case .normal:
            Color.clear
        case .focused:
            AppColors.surfaceElevated
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        case .playing:
            AppColors.accent.opacity(0.15)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        case .focusedAndPlaying:
            AppColors.surfaceElevated
                .overlay(
                    AppColors.accent.opacity(0.15)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        }
    }
    
    private func formatAyahNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private var displayArabicText: String {
        guard ayah.numberInSurah == 1,
              ayah.surahNumber != 1,
              ayah.surahNumber != 9 else {
            return ayah.arabicText
        }

        let words = ayah.arabicText.split(
            maxSplits: 4,
            whereSeparator: { $0.isWhitespace }
        )
        guard words.count == 5 else { return ayah.arabicText }

        let prefix = words.prefix(4).map(normalizedArabicWord)
        guard prefix == ["بسم", "الله", "الرحمن", "الرحيم"] else {
            return ayah.arabicText
        }

        return String(words[4])
    }

    private func normalizedArabicWord(_ word: Substring) -> String {
        let scalars = word.unicodeScalars.compactMap { scalar -> UnicodeScalar? in
            if CharacterSet.nonBaseCharacters.contains(scalar) {
                return nil
            }
            if scalar.value == 0x0671 {
                return UnicodeScalar(0x0627)
            }
            return scalar
        }
        return String(String.UnicodeScalarView(scalars))
    }
}
