import Foundation

/// Repository for Quran search
@MainActor
final class SearchRepository {
    private let apiClient = APIClient.shared
    
    /// Search for a keyword in a specific edition
    func search(keyword: String, edition: String) async throws -> [Ayah] {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        let result: SearchResultDTO = try await apiClient.fetchAPIResponse(
            .search(keyword: keyword, edition: edition)
        )
        
        return result.matches.map { Ayah(from: $0) }
    }
}
