import SwiftUI

@Observable
@MainActor
final class SettingsViewModel {
    var translations: ViewState<[Edition]> = .idle
    var reciters: ViewState<[Edition]> = .idle
    
    private let editionRepository = EditionRepository()
    
    func loadEditions() async {
        // Load translations
        translations = .loading
        do {
            let editions = try await editionRepository.fetchTranslationEditions()
            translations = editions.isEmpty ? .empty("No translations") : .content(editions)
        } catch let error as QuranError {
            translations = .error(error)
        } catch {
            translations = .error(.unknown)
        }
        
        // Load reciters
        reciters = .loading
        do {
            let editions = try await editionRepository.fetchReciters()
            reciters = editions.isEmpty ? .empty("No reciters") : .content(editions)
        } catch let error as QuranError {
            reciters = .error(error)
        } catch {
            reciters = .error(.unknown)
        }
    }
    
    func translationName(for identifier: String) -> String {
        if case .content(let editions) = translations {
            return editions.first { $0.identifier == identifier }?.englishName ?? identifier
        }
        return identifier
    }
    
    func reciterName(for identifier: String) -> String {
        if case .content(let editions) = reciters {
            return editions.first { $0.identifier == identifier }?.englishName ?? identifier
        }
        return identifier
    }
}
