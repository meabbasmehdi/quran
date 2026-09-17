import Foundation
import Observation

/// A class responsible for storing and recalling focus targets per screen.
@Observable @MainActor
final class FocusMemory {
    
    /// Defines the major screens in the application where focus state should be preserved.
    enum Screen: String, Hashable {
        case home
        case reader
        case settings
        case search
        case onboarding
    }
    
    /// Private dictionary storing the last focused item per screen.
    private var storedFocus: [String: FocusTarget] = [:]
    
    /// Store a focus target for a specific screen.
    /// - Parameters:
    ///   - target: The target to remember.
    ///   - screen: The screen associated with the target.
    func store(_ target: FocusTarget, forScreen screen: Screen) {
        storedFocus[screen.rawValue] = target
    }
    
    /// Recall the last focused target for a specific screen.
    /// - Parameter screen: The screen for which to recall focus.
    /// - Returns: The stored focus target, or nil if none was saved.
    func recall(forScreen screen: Screen) -> FocusTarget? {
        return storedFocus[screen.rawValue]
    }
    
    /// Clear the stored focus for a specific screen.
    /// - Parameter screen: The screen for which to clear focus.
    func clear(forScreen screen: Screen) {
        storedFocus.removeValue(forKey: screen.rawValue)
    }
    
    /// Clear all stored focus data.
    func clearAll() {
        storedFocus.removeAll()
    }
}
