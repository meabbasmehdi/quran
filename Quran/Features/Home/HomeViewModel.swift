import SwiftUI

@Observable
@MainActor
final class HomeViewModel {
    // State
    var surahListState: ViewState<[Surah]> = .idle
    var selectedTab: HomeTab = .surah
    var selectedSurahIndex: Int? = nil  // Currently focused surah number
    var selectedJuzIndex: Int? = nil    // Currently focused juz number
    
    // Dependencies
    private let surahRepository = SurahRepository()
    
    // Computed
    var selectedSurah: Surah? {
        guard let index = selectedSurahIndex,
              case .content(let surahs) = surahListState else { return nil }
        return surahs.first { $0.number == index }
    }
    
    func loadSurahs() async {
        guard !surahListState.isLoading else { return }
        surahListState = .loading
        do {
            let surahs = try await surahRepository.fetchSurahList()
            surahListState = surahs.isEmpty ? .empty("No surahs found") : .content(surahs)
        } catch let error as QuranError {
            surahListState = .error(error)
        } catch {
            surahListState = .error(.unknown)
        }
    }
}
