import Foundation

enum QuranError: Error, Equatable, LocalizedError {
    case noInternet
    case timeout
    case invalidResponse
    case decodingFailed
    case invalidSurah
    case invalidJuz
    case audioUnavailable
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noInternet: return "No internet connection. Please check your network."
        case .timeout: return "Request timed out. Please try again."
        case .invalidResponse: return "Received an invalid response from the server."
        case .decodingFailed: return "Failed to process the data."
        case .invalidSurah: return "Invalid Surah number."
        case .invalidJuz: return "Invalid Juz number."
        case .audioUnavailable: return "Audio is currently unavailable."
        case .serverError(let code): return "Server error (\(code)). Please try again later."
        case .unknown: return "An unexpected error occurred."
        }
    }
}
