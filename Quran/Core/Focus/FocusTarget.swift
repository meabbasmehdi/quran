import Foundation

/// Defines the main navigation tabs for the Home screen.
enum HomeTab: String, CaseIterable, Hashable {
    case surah = "Surah"
    case juz = "Juz"
}

/// Represents every focusable element in the application.
/// This is the single source of truth for what CAN be focused.
enum FocusTarget: Hashable {
    // Home - Top Actions
    case search
    case settings

    // Search
    case searchField
    case searchClear
    case searchResult(Int)
    
    // Home - Navigation
    case homeTab(HomeTab)
    case homeRetry
    
    // Home - Content Lists
    case surah(Int)  // surah number 1-114
    case juz(Int)    // juz number 1-30
    
    // Home - Continue
    case continueReading
    case continueListening
    
    // Reader
    case readerBack
    case readerAyah(Int)  // ayah numberInSurah
    case readerReciter
    case readerPlayPause
    case readerPrevious
    case readerNext
    case readerPlayerShow
    case readerPlayerClose
    case readerQuickSettings
    case readerOverlayClose
    case readerOverlayFontDecrease
    case readerOverlayFontIncrease
    case readerOverlayTranslation
    case readerOverlayReciter
    
    // Settings
    case settingsTranslation
    case settingsReciter
    case settingsFont
    case settingsFontOption(String)
    case settingsFontSize
    case settingsFontSizeDecrease
    case settingsFontSizeIncrease
    case settingsAbout
    case settingsDataSources
    
    // Onboarding
    case onboardingContinue
    case onboardingSkip
    case onboardingBack
    case onboardingItem(Int)  // list item index
    case onboardingFontOption(String)
    case onboardingFontDecrease
    case onboardingFontIncrease
}
