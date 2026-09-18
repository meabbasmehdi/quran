import Foundation

/// Defines logical focus zones within each screen.
/// Used to manage spatial navigation between groups of focusable elements.
enum FocusZone: Hashable {
    // Home zones
    case homeTopActions
    case homeNavigation  
    case homeContentList
    case homeContinue
    
    // Reader zones
    case readerContent
    case readerControls
    
    // Settings
    case settingsList

    // Overlays
    case overlay
    
    // Onboarding
    case onboardingContent
    case onboardingActions
}
