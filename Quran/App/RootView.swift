import SwiftUI

/// Root view that handles the initial routing between onboarding and main app
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    @Environment(PreferencesStore.self) private var preferences
    
    var body: some View {
        Group {
            if !appState.isReady {
                // Splash / loading
                SplashView()
            } else if !preferences.hasCompletedOnboarding {
                // Onboarding flow
                OnboardingView()
            } else {
                // Main app with navigation
                MainNavigationView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isReady)
        .animation(.easeInOut(duration: 0.3), value: preferences.hasCompletedOnboarding)
    }
}

// MARK: - Splash Screen

struct SplashView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: AppSpacing.lg) {
                Text("بِسْمِ ٱللَّهِ")
                    .font(AppTypography.arabicDisplay)
                    .foregroundStyle(AppColors.arabicText)
                Text("Quran")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }
}

// MARK: - Main Navigation

/// Main navigation container with NavigationStack
struct MainNavigationView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .reader(let source):
                        QuranReaderView(source: source)
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

