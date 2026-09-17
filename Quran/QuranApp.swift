import SwiftUI

@main
struct QuranApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .buttonStyle(QuranButtonStyle())
                .environment(appState)
                .environment(appState.router)
                .environment(appState.preferences)
                .environment(appState.readingState)
                .environment(appState.playbackState)
                .environment(appState.focusCoordinator)
                .environment(appState.audioPlayer)
                .onAppear {
                    appState.initialize()
                }
        }
    }
}
