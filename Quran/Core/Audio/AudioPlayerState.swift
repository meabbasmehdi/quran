import Foundation

enum AudioPlayerState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case buffering
    case completed
    case failed(String)
    
    var isActive: Bool {
        switch self {
        case .playing, .paused, .buffering, .loading: return true
        default: return false
        }
    }
    
    var isPlaying: Bool {
        self == .playing
    }
}
