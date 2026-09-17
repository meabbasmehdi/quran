import SwiftUI

struct JuzListView: View {
    @Binding var selectedJuzIndex: Int?
    @FocusState.Binding var focusTarget: FocusTarget?
    @Environment(AppRouter.self) private var router
    
    static let juzStartingSurahs: [(juz: Int, surah: String, surahNumber: Int)] = [
        (1, "Al-Fatihah", 1), (2, "Al-Baqarah", 2), (3, "Al-Baqarah", 2),
        (4, "Ali 'Imran", 3), (5, "An-Nisa'", 4), (6, "An-Nisa'", 4),
        (7, "Al-Ma'idah", 5), (8, "Al-An'am", 6), (9, "Al-A'raf", 7),
        (10, "Al-Anfal", 8), (11, "At-Tawbah", 9), (12, "Hud", 11),
        (13, "Yusuf", 12), (14, "Al-Hijr", 15), (15, "Al-Isra", 17),
        (16, "Al-Kahf", 18), (17, "Al-Anbiya", 21), (18, "Al-Mu'minun", 23),
        (19, "Al-Furqan", 25), (20, "An-Naml", 27), (21, "Al-Ankabut", 29),
        (22, "Al-Ahzab", 33), (23, "Ya-Sin", 36), (24, "Az-Zumar", 39),
        (25, "Fussilat", 41), (26, "Al-Ahqaf", 46), (27, "Adh-Dhariyat", 51),
        (28, "Al-Mujadila", 58), (29, "Al-Mulk", 67), (30, "An-Naba", 78)
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(Self.juzStartingSurahs, id: \.juz) { item in
                    juzButton(for: item)
                }
            }
            .padding(.vertical, AppSpacing.md)
            .focusSection()
        }
        .onChange(of: focusTarget) { _, newValue in
            if case .juz(let number) = newValue {
                selectedJuzIndex = number
            }
        }
    }

    private func juzButton(for item: (juz: Int, surah: String, surahNumber: Int)) -> some View {
        let target = FocusTarget.juz(item.juz)

        return Button {
            router.navigateToReader(source: .juz(item.juz))
        } label: {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Text("\(item.juz)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Juz \(item.juz)")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Starts with \(item.surah)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(focusTarget == target ? AppColors.surfaceElevated : Color.clear)
            .cornerRadius(AppRadius.medium)
        }
        .buttonStyle(QuranButtonStyle())
        .focused($focusTarget, equals: target)
        .quranFocusStyle(isFocused: focusTarget == target)
    }
}
