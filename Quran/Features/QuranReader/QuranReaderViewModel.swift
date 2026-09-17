import SwiftUI

/// Ayah visual state in the reader
enum AyahDisplayState {
    case normal
    case focused
    case playing
    case focusedAndPlaying
}

@Observable
@MainActor
final class QuranReaderViewModel {
    let readingSource: ReadingSource
    
    // State
    var viewState: ViewState<[Ayah]> = .idle
    var surahInfo: Surah? = nil
    var juzSurahs: [Surah] = []
    var focusedAyahNumber: Int? = nil
    var playingAyahNumber: Int? = nil
    var showQuickSettings: Bool = false
    
    // Dependencies
    private let surahRepository = SurahRepository()
    private let juzRepository = JuzRepository()
    
    init(source: ReadingSource) {
        self.readingSource = source
    }
    
    var ayahs: [Ayah] {
        viewState.contentValue ?? []
    }
    
    var headerTitle: String {
        switch readingSource {
        case .surah: return surahInfo?.englishName ?? ""
        case .juz(let n): return "Juz \(n)"
        }
    }
    
    var headerArabicTitle: String {
        surahInfo?.arabicName ?? ""
    }
    
    func displayState(for ayah: Ayah) -> AyahDisplayState {
        let isFocused = focusedAyahNumber == ayah.numberInSurah
        let isPlaying = playingAyahNumber == ayah.numberInSurah
        switch (isFocused, isPlaying) {
        case (true, true): return .focusedAndPlaying
        case (true, false): return .focused
        case (false, true): return .playing
        case (false, false): return .normal
        }
    }
    
    func loadContent(preferences: PreferencesStore) async {
        guard !viewState.isLoading else { return }
        viewState = .loading
        
        do {
            switch readingSource {
            case .surah(let number):
                // Fetch surah list to get metadata
                let surahs = try await surahRepository.fetchSurahList()
                surahInfo = surahs.first { $0.number == number }
                
                // Fetch Arabic + translation
                let ayahs = try await surahRepository.fetchSurahDetail(
                    number: number,
                    translationEdition: preferences.selectedTranslation
                )
                viewState = ayahs.isEmpty ? .empty("No ayahs found") : .content(ayahs)
                
            case .juz(let number):
                let result = try await juzRepository.fetchJuz(
                    number: number,
                    translationEdition: preferences.selectedTranslation
                )
                juzSurahs = result.surahs
                surahInfo = result.surahs.first
                viewState = result.ayahs.isEmpty ? .empty("No ayahs found") : .content(result.ayahs)
            }
        } catch let error as QuranError {
            viewState = .error(error)
        } catch {
            viewState = .error(.unknown)
        }
    }
    
    func saveReadingState(store: ReadingStateStore) {
        guard let ayah = focusedAyahNumber else { return }
        switch readingSource {
        case .surah(let n):
            store.save(surah: n, juz: nil, ayah: ayah, scrollPosition: 0, mode: "surah")
        case .juz(let n):
            store.save(surah: nil, juz: n, ayah: ayah, scrollPosition: 0, mode: "juz")
        }
    }
}
