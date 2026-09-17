import Foundation
import Observation

@MainActor
@Observable
class PlaybackStateStore {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let surahNumber = "playbackState_surahNumber"
        static let ayahNumber = "playbackState_ayahNumber"
        static let reciterIdentifier = "playbackState_reciterIdentifier"
        static let playbackTime = "playbackState_playbackTime"
        static let duration = "playbackState_duration"
    }
    
    var surahNumber: Int? {
        get { defaults.object(forKey: Keys.surahNumber) as? Int }
        set { defaults.set(newValue, forKey: Keys.surahNumber) }
    }
    
    var ayahNumber: Int? {
        get { defaults.object(forKey: Keys.ayahNumber) as? Int }
        set { defaults.set(newValue, forKey: Keys.ayahNumber) }
    }
    
    var reciterIdentifier: String? {
        get { defaults.string(forKey: Keys.reciterIdentifier) }
        set { defaults.set(newValue, forKey: Keys.reciterIdentifier) }
    }
    
    var playbackTime: Double {
        get { defaults.double(forKey: Keys.playbackTime) }
        set { defaults.set(newValue, forKey: Keys.playbackTime) }
    }
    
    var duration: Double {
        get { defaults.double(forKey: Keys.duration) }
        set { defaults.set(newValue, forKey: Keys.duration) }
    }
    
    var hasPlaybackState: Bool {
        return surahNumber != nil && ayahNumber != nil && reciterIdentifier != nil
    }
    
    func save(surah: Int, ayah: Int, reciter: String, time: Double, duration: Double) {
        surahNumber = surah
        ayahNumber = ayah
        reciterIdentifier = reciter
        playbackTime = time
        self.duration = duration
    }
    
    func clear() {
        defaults.removeObject(forKey: Keys.surahNumber)
        defaults.removeObject(forKey: Keys.ayahNumber)
        defaults.removeObject(forKey: Keys.reciterIdentifier)
        defaults.removeObject(forKey: Keys.playbackTime)
        defaults.removeObject(forKey: Keys.duration)
    }
}
