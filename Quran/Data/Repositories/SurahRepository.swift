import Foundation

/// Repository for Surah-related data access
@MainActor
final class SurahRepository {
    private let apiClient = APIClient.shared
    private let cache = CacheManager.shared
    
    private let surahListCacheKey = "surah_list"
    
    /// Fetch all 114 surahs. Uses cache if available.
    func fetchSurahList() async throws -> [Surah] {
        // Check cache first
        if let cached: [SurahDTO] = cache.retrieve(forKey: surahListCacheKey) {
            return cached.map { Surah(from: $0) }
        }
        
        let dtos: [SurahDTO]
        do {
            // This endpoint is a small static JSON file and avoids the timeout
            // currently affecting the primary Al Quran Cloud Surah-list route.
            let fallbackDTOs: [FallbackSurahDTO] = try await apiClient.fetch(.surahListFallback)
            dtos = fallbackDTOs.enumerated().map { index, dto in
                dto.asSurahDTO(number: index + 1)
            }
        } catch {
            // Keep the existing provider as a transparent fallback.
            dtos = try await apiClient.fetchAPIResponse(.surahList)
        }
        
        // Cache for 24 hours
        cache.store(dtos, forKey: surahListCacheKey, ttl: 86400)
        
        return dtos.map { Surah(from: $0) }
    }
    
    /// Fetch surah detail with Arabic text and optionally translation
    func fetchSurahDetail(
        number: Int,
        arabicEdition: String = "quran-uthmani",
        translationEdition: String? = nil
    ) async throws -> [Ayah] {
        // Fetch Arabic text
        let arabicDetail: SurahDetailDTO = try await apiClient.fetchAPIResponse(
            .surahDetail(number: number, edition: arabicEdition)
        )
        
        var ayahs = arabicDetail.ayahs.map { Ayah(from: $0, surahNumber: number) }
        
        // Fetch translation if specified
        if let translationEdition {
            let translationDetail: SurahDetailDTO = try await apiClient.fetchAPIResponse(
                .surahDetail(number: number, edition: translationEdition)
            )
            
            // Merge translation text into ayahs
            for (index, transAyah) in translationDetail.ayahs.enumerated() {
                if index < ayahs.count {
                    ayahs[index].translationText = transAyah.text
                }
            }
        }
        
        return ayahs
    }
    
    /// Fetch surah with audio edition (for per-ayah audio URLs)
    func fetchSurahWithAudio(
        number: Int,
        reciterEdition: String
    ) async throws -> [Ayah] {
        let detail: SurahDetailDTO = try await apiClient.fetchAPIResponse(
            .surahDetail(number: number, edition: reciterEdition)
        )
        return detail.ayahs.map { Ayah(from: $0, surahNumber: number) }
    }
}
