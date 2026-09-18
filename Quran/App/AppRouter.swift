import SwiftUI

/// All navigable routes in the application
enum AppRoute: Hashable {
    case onboarding
    case home
    case reader(ReadingSource)
    case settings
}

/// Central navigation coordinator - single source of truth for navigation
@Observable
@MainActor
final class AppRouter {
    var path = NavigationPath()
    
    /// The root route - determined by onboarding state
    var rootRoute: AppRoute = .home
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func goToRoot() {
        path = NavigationPath()
    }
    
    func navigateToReader(source: ReadingSource) {
        navigate(to: .reader(source))
    }
}
