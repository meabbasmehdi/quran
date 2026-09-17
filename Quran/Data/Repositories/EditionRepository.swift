import Foundation

/// Repository for edition (reciter/translation) data access
@MainActor
final class EditionRepository {
    private let apiClient = APIClient.shared
    private let cache = CacheManager.shared
    
    private let audioCacheKey = "audio_editions"
    private let translationCacheKey = "translation_editions"
    
    /// Fetch all audio editions (reciters)
    func fetchAudioEditions() async throws -> [Edition] {
        if let cached: [EditionDTO] = cache.retrieve(forKey: audioCacheKey) {
            return cached.map { Edition(from: $0) }
        }
        
        let dtos: [EditionDTO] = try await apiClient.fetchAPIResponse(.audioEditions)
        cache.store(dtos, forKey: audioCacheKey, ttl: 86400)
        return dtos.map { Edition(from: $0) }
    }
    
    /// Fetch only Arabic verse-by-verse reciters
    func fetchReciters() async throws -> [Edition] {
        let all = try await fetchAudioEditions()
        return all.filter { $0.language == "ar" && $0.type == .versebyverse }
    }
    
    /// Fetch all translation editions
    func fetchTranslationEditions() async throws -> [Edition] {
        if let cached: [EditionDTO] = cache.retrieve(forKey: translationCacheKey) {
            return cached.map { Edition(from: $0) }
        }
        
        let dtos: [EditionDTO] = try await apiClient.fetchAPIResponse(.translationEditions)
        cache.store(dtos, forKey: translationCacheKey, ttl: 86400)
        return dtos.map { Edition(from: $0) }
    }
    
    /// Fetch English translations only
    func fetchEnglishTranslations() async throws -> [Edition] {
        let all = try await fetchTranslationEditions()
        return all.filter { $0.language == "en" }
    }
}
