import Foundation
import Observation

@MainActor
@Observable
class ReadingStateStore {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let lastSurahNumber = "readingState_lastSurahNumber"
        static let lastJuzNumber = "readingState_lastJuzNumber"
        static let lastAyahNumber = "readingState_lastAyahNumber"
        static let scrollPosition = "readingState_scrollPosition"
        static let lastMode = "readingState_lastMode"
        static let lastUpdateTime = "readingState_lastUpdateTime"
    }
    
    var lastSurahNumber: Int? {
        get { defaults.object(forKey: Keys.lastSurahNumber) as? Int }
        set { defaults.set(newValue, forKey: Keys.lastSurahNumber) }
    }
    
    var lastJuzNumber: Int? {
        get { defaults.object(forKey: Keys.lastJuzNumber) as? Int }
        set { defaults.set(newValue, forKey: Keys.lastJuzNumber) }
    }
    
    var lastAyahNumber: Int? {
        get { defaults.object(forKey: Keys.lastAyahNumber) as? Int }
        set { defaults.set(newValue, forKey: Keys.lastAyahNumber) }
    }
    
    var scrollPosition: Double? {
        get { defaults.object(forKey: Keys.scrollPosition) as? Double }
        set { defaults.set(newValue, forKey: Keys.scrollPosition) }
    }
    
    var lastMode: String? {
        get { defaults.string(forKey: Keys.lastMode) }
        set { defaults.set(newValue, forKey: Keys.lastMode) }
    }
    
    var lastUpdateTime: Date? {
        get { defaults.object(forKey: Keys.lastUpdateTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastUpdateTime) }
    }
    
    var hasReadingState: Bool {
        return lastAyahNumber != nil && lastMode != nil
    }
    
    func save(surah: Int?, juz: Int?, ayah: Int, scrollPosition: Double, mode: String) {
        lastSurahNumber = surah
        lastJuzNumber = juz
        lastAyahNumber = ayah
        self.scrollPosition = scrollPosition
        lastMode = mode
        lastUpdateTime = Date()
    }
    
    func clear() {
        defaults.removeObject(forKey: Keys.lastSurahNumber)
        defaults.removeObject(forKey: Keys.lastJuzNumber)
        defaults.removeObject(forKey: Keys.lastAyahNumber)
        defaults.removeObject(forKey: Keys.scrollPosition)
        defaults.removeObject(forKey: Keys.lastMode)
        defaults.removeObject(forKey: Keys.lastUpdateTime)
    }
}
