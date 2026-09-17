import SwiftUI

/// ViewModel for Quran search functionality
@Observable
@MainActor
final class SearchViewModel {
    var query: String = ""
    var searchState: ViewState<[Ayah]> = .idle
    
    private let searchRepository = SearchRepository()
    private var searchTask: Task<Void, Never>?
    
    /// The edition to search in (uses the user's selected translation)
    var searchEdition: String = "en.sahih"
    
    var hasResults: Bool {
        if case .content(let results) = searchState {
            return !results.isEmpty
        }
        return false
    }
    
    func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchState = .idle
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        searchTask = Task {
            searchState = .loading
            
            do {
                let results = try await searchRepository.search(
                    keyword: trimmed,
                    edition: searchEdition
                )
                
                guard !Task.isCancelled else { return }
                
                if results.isEmpty {
                    searchState = .empty("No results found for \"\(trimmed)\"")
                } else {
                    searchState = .content(results)
                }
            } catch let error as QuranError {
                guard !Task.isCancelled else { return }
                searchState = .error(error)
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .error(.unknown)
            }
        }
    }
    
    func clearSearch() {
        query = ""
        searchState = .idle
        searchTask?.cancel()
    }
}
