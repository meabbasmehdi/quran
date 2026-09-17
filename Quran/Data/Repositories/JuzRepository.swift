import Foundation

/// Repository for Juz-related data access  
@MainActor
final class JuzRepository {
    private let apiClient = APIClient.shared
    
    /// Fetch juz detail with Arabic text and optionally translation
    func fetchJuz(
        number: Int,
        arabicEdition: String = "quran-uthmani",
        translationEdition: String? = nil
    ) async throws -> (ayahs: [Ayah], surahs: [Surah]) {
        let juzDTO: JuzDTO = try await apiClient.fetchAPIResponse(
            .juz(number: number, edition: arabicEdition)
        )
        
        var ayahs = juzDTO.ayahs.map { Ayah(from: $0) }
        let surahs = juzDTO.surahs.values.map { Surah(from: $0) }
            .sorted { $0.number < $1.number }
        
        // Fetch translation if specified
        if let translationEdition {
            let transJuz: JuzDTO = try await apiClient.fetchAPIResponse(
                .juz(number: number, edition: translationEdition)
            )
            for (index, transAyah) in transJuz.ayahs.enumerated() {
                if index < ayahs.count {
                    ayahs[index].translationText = transAyah.text
                }
            }
        }
        
        return (ayahs, surahs)
    }
}
