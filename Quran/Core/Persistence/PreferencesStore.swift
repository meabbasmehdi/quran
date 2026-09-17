import Foundation
import Observation

@MainActor
@Observable
final class PreferencesStore {
    @ObservationIgnored private let defaults: UserDefaults
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTranslation = "selectedTranslation"
        static let selectedReciter = "selectedReciter"
        static let arabicFontName = "arabicFontName"
        static let fontSize = "fontSize"
    }
    
    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }
    
    var selectedTranslation: String {
        didSet { defaults.set(selectedTranslation, forKey: Keys.selectedTranslation) }
    }
    
    var selectedReciter: String {
        didSet { defaults.set(selectedReciter, forKey: Keys.selectedReciter) }
    }
    
    var arabicFontName: String {
        didSet { defaults.set(arabicFontName, forKey: Keys.arabicFontName) }
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

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        selectedTranslation = defaults.string(forKey: Keys.selectedTranslation) ?? "en.sahih"
        selectedReciter = defaults.string(forKey: Keys.selectedReciter) ?? "ar.alafasy"
        arabicFontName = defaults.string(forKey: Keys.arabicFontName) ?? ""
        let storedFontSize = defaults.double(forKey: Keys.fontSize)
        fontSize = storedFontSize > 0 ? storedFontSize : 36.0
    }
}
