import Foundation
import Observation

@MainActor
@Observable
class PreferencesStore {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTranslation = "selectedTranslation"
        static let selectedReciter = "selectedReciter"
        static let arabicFontName = "arabicFontName"
        static let fontSize = "fontSize"
    }
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    var selectedTranslation: String {
        get { defaults.string(forKey: Keys.selectedTranslation) ?? "en.sahih" }
        set { defaults.set(newValue, forKey: Keys.selectedTranslation) }
    }
    
    var selectedReciter: String {
        get { defaults.string(forKey: Keys.selectedReciter) ?? "ar.alafasy" }
        set { defaults.set(newValue, forKey: Keys.selectedReciter) }
    }
    
    var arabicFontName: String {
        get { defaults.string(forKey: Keys.arabicFontName) ?? "" }
        set { defaults.set(newValue, forKey: Keys.arabicFontName) }
    }
    
    var fontSize: Double {
        didSet {
            let clamped = max(22.0, min(50.0, fontSize))
            if fontSize != clamped {
                fontSize = clamped
            } else {
                defaults.set(fontSize, forKey: Keys.fontSize)
            }
        }
    }

    init() {
        let storedFontSize = defaults.double(forKey: Keys.fontSize)
        fontSize = storedFontSize > 0 ? storedFontSize : 36.0
    }
}
