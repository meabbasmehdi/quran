import SwiftUI
import UIKit

public enum ArabicFontChoice: String, CaseIterable, Identifiable, Hashable {
    case standard = ""
    case geezaPro = "GeezaPro"
    case alBayan = "AlBayan"
    case kufi = "KufiStandardGK"
    case naskh = "DecoTypeNaskh"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .standard: return "Default"
        case .geezaPro: return "Geeza Pro"
        case .alBayan: return "Al Bayan"
        case .kufi: return "Kufi"
        case .naskh: return "Naskh"
        }
    }

    fileprivate var postScriptName: String? {
        self == .standard ? nil : rawValue
    }

    public static func storedValue(_ value: String) -> ArabicFontChoice {
        switch value {
        case "system-serif": return .geezaPro
        case "system-rounded": return .alBayan
        default: return ArabicFontChoice(rawValue: value) ?? .standard
        }
    }
}

public enum AppTypography {
    public static let arabicDisplay = Font.system(size: 42, weight: .regular)
    public static let arabicLarge = Font.system(size: 36, weight: .regular)
    public static let arabicMedium = Font.system(size: 30, weight: .regular)
    public static let arabicSmall = Font.system(size: 26, weight: .regular)
    
    public static func arabicFont(size: CGFloat, name: String = "") -> Font {
        let choice = ArabicFontChoice.storedValue(name)
        guard let postScriptName = choice.postScriptName,
              UIFont(name: postScriptName, size: size) != nil else {
            return .system(size: size, weight: .regular)
        }
        return .custom(postScriptName, size: size)
    }
    
    public static let translationBody = Font.system(size: 22, weight: .regular)
    public static let translationSmall = Font.system(size: 18, weight: .regular)
    public static let title = Font.system(size: 38, weight: .semibold)
    public static let headline = Font.system(size: 28, weight: .medium)
    public static let body = Font.system(size: 22, weight: .regular)
    public static let bodyMedium = Font.system(size: 22, weight: .medium)
    public static let caption = Font.system(size: 18, weight: .regular)
    public static let captionMedium = Font.system(size: 18, weight: .medium)
    public static let surahNumber = Font.system(size: 20, weight: .bold, design: .rounded)
}
