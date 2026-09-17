import Foundation

struct AyahDTO: Codable {
    let number: Int            // Global ayah number (1-6236)
    let audio: String?         // Audio URL, only for audio editions
    let audioSecondary: [String]?
    let text: String
    let numberInSurah: Int
    let juz: Int
    let manzil: Int
    let page: Int
    let ruku: Int
    let hizbQuarter: Int
    let sajda: SajdaValue
}

/// Handles the polymorphic `sajda` field which can be `false` or `{"id":1,...}`
enum SajdaValue: Codable {
    case none
    case info(SajdaInfo)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolVal = try? container.decode(Bool.self) {
            self = boolVal ? .info(SajdaInfo(id: 0, recommended: false, obligatory: false)) : .none
        } else if let info = try? container.decode(SajdaInfo.self) {
            self = .info(info)
        } else {
            self = .none
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            try container.encode(false)
        case .info(let info):
            try container.encode(info)
        }
    }
    
    var hasSajda: Bool {
        if case .info = self { return true }
        return false
    }
}

struct SajdaInfo: Codable {
    let id: Int
    let recommended: Bool
    let obligatory: Bool
}
