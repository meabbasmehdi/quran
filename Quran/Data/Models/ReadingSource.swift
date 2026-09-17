import Foundation

enum ReadingSource: Hashable {
    case surah(Int)
    case juz(Int)
    
    var title: String {
        switch self {
        case .surah(let n): return "Surah \(n)"
        case .juz(let n): return "Juz \(n)"
        }
    }
}
