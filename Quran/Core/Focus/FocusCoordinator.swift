import Foundation
import Observation

/// Coordinates focus management across the application.
/// Interacts with SwiftUI focus and programmatic focus requests.
@Observable @MainActor
final class FocusCoordinator {
    
    /// The current logical focus target reported by SwiftUI views.
    private(set) var currentTarget: FocusTarget?
    
    /// The current logical focus zone.
    private(set) var currentZone: FocusZone?
    
    /// A programmatic focus request waiting to be applied by SwiftUI views.
    private(set) var pendingRequest: FocusTarget?
    
    /// The previously focused target, commonly used for overlay restore.
    private(set) var previousTarget: FocusTarget?
    
    /// Memory for storing focus per screen to resume later.
    let memory = FocusMemory()
    
    /// Guard against infinite focus loops.
    private var isUpdating = false
    
    /// Called by views when SwiftUI focus changes (user moved remote)
    /// - Parameters:
    ///   - target: The newly focused target.
    ///   - zone: The zone of the newly focused target.
    func reportFocus(_ target: FocusTarget, in zone: FocusZone) {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        
        if zone != .overlay {
            previousTarget = currentTarget
        }
        currentTarget = target
        currentZone = zone
        
        // Clear pending if it matches what was just reported
        if pendingRequest == target {
            pendingRequest = nil
        }
    }
    
    /// Called programmatically to request a focus move to a specific target.
    /// - Parameters:
    ///   - target: The target to move focus to.
    ///   - zone: Optional zone to update along with the request.
    func requestFocus(_ target: FocusTarget, in zone: FocusZone? = nil) {
        guard !isUpdating else { return }
        pendingRequest = target
        if let zone { currentZone = zone }
    }
    
    /// Store current focus for a specific screen. Should be called before navigating away.
    /// - Parameter screen: The screen context.
    func storeFocus(forScreen screen: FocusMemory.Screen) {
        if let currentTarget {
            memory.store(currentTarget, forScreen: screen)
        }
    }
    
    /// Restore focus for a specific screen. Should be called when navigating back.
    /// - Parameter screen: The screen context.
    func restoreFocus(forScreen screen: FocusMemory.Screen) {
        if let saved = memory.recall(forScreen: screen) {
            requestFocus(saved)
        }
    }
    
    /// Store the current focus and request focus on an initial target within an overlay.
    /// - Parameter initialTarget: The first target to focus in the overlay.
    func pushOverlayFocus(initialTarget: FocusTarget) {
        previousTarget = currentTarget
        requestFocus(initialTarget, in: .overlay)
    }
    
    /// Restore focus to the target that was active before an overlay opened.
    func popOverlayFocus() {
        if let prev = previousTarget {
            pendingRequest = prev
            previousTarget = nil
        }
    }
    
    /// Consume and clear the pending request. 
    /// This is typically used by SwiftUI view modifiers reacting to focus requests.
    /// - Returns: The consumed target request.
    func consumePendingRequest() -> FocusTarget? {
        let request = pendingRequest
        pendingRequest = nil
        return request
    }
}
