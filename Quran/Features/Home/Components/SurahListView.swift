import SwiftUI

struct SurahListView: View {
    let surahs: [Surah]
    @Binding var selectedSurahIndex: Int?
    @FocusState.Binding var focusTarget: FocusTarget?
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(surahs) { surah in
                    SurahRowView(
                        surah: surah,
                        isFocused: focusTarget == .surah(surah.number)
                    ) {
                        router.navigateToReader(source: .surah(surah.number))
                    }
                    .focused($focusTarget, equals: .surah(surah.number))
                }
            }
            .padding(.vertical, AppSpacing.md)
            .focusSection()
        }
        .onChange(of: focusTarget) { _, newValue in
            if case .surah(let number) = newValue {
                selectedSurahIndex = number
            }
        }
    }
}
