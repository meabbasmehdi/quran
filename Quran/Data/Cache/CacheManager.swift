import Foundation

/// Simple in-memory + UserDefaults cache with TTL support
final class CacheManager: @unchecked Sendable {
    static let shared = CacheManager()
    
    private struct CacheEntry<T: Codable>: Codable {
        let data: T
        let timestamp: Date
        let ttl: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    private let defaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "com.invotyx.quran.cache", attributes: .concurrent)
    private var memoryCache: [String: Any] = [:]
    
    private let keyPrefix = "com.invotyx.quran.cache."
    
    private init() {}
    
    /// Store a value with a TTL (in seconds)
    func store<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval = 3600) {
        let entry = CacheEntry(data: value, timestamp: Date(), ttl: ttl)
        
        // Memory cache
        queue.async(flags: .barrier) {
            self.memoryCache[key] = entry
        }
        
        // Persist to UserDefaults
        if let data = try? JSONEncoder().encode(entry) {
            defaults.set(data, forKey: keyPrefix + key)
        }
    }
    
    /// Retrieve a cached value. Returns nil if expired or missing.
    func retrieve<T: Codable>(forKey key: String) -> T? {
        // Check memory cache first
        var memoryResult: CacheEntry<T>? = nil
        queue.sync {
            memoryResult = memoryCache[key] as? CacheEntry<T>
        }
        
        if let entry = memoryResult, !entry.isExpired {
            return entry.data
        }
        
        // Fall back to UserDefaults
        guard let data = defaults.data(forKey: keyPrefix + key),
              let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data),
              !entry.isExpired else {
            return nil
        }
        
        // Repopulate memory cache
        queue.async(flags: .barrier) {
            self.memoryCache[key] = entry
        }
        
        return entry.data
    }
    
    /// Remove a specific cache entry
    func remove(forKey key: String) {
        queue.async(flags: .barrier) {
            self.memoryCache.removeValue(forKey: key)
        }
        defaults.removeObject(forKey: keyPrefix + key)
    }
    
    /// Clear all cache entries
    func clearAll() {
        queue.async(flags: .barrier) {
            self.memoryCache.removeAll()
        }
        // Clear UserDefaults cache entries
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(keyPrefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
