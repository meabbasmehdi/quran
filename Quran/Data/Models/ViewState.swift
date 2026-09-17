import Foundation

enum ViewState<T> {
    case idle
    case loading
    case content(T)
    case empty(String)
    case error(QuranError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var contentValue: T? {
        if case .content(let value) = self { return value }
        return nil
    }
}
