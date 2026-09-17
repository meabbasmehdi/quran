import SwiftUI

/// Lightweight application state holder.
/// Owns shared service instances and coordinates app lifecycle.
@Observable
@MainActor
final class AppState {
    let preferences = PreferencesStore()
    let readingState = ReadingStateStore()
    let playbackState = PlaybackStateStore()
    let focusCoordinator = FocusCoordinator()
    let router = AppRouter()
    let audioPlayer = AudioPlayerManager()
    
    /// Whether the app has finished initial loading
    var isReady: Bool = false
    
    func initialize() {
        // Set initial route based on onboarding
        if preferences.hasCompletedOnboarding {
            router.rootRoute = .home
        } else {
            router.rootRoute = .onboarding
        }
        isReady = true
    }
}
