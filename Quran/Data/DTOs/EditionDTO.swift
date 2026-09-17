import Foundation

struct EditionDTO: Codable, Hashable {
    let identifier: String
    let language: String
    let name: String           // Native name
    let englishName: String
    let format: String         // "audio" or "text"
    let type: String           // "versebyverse", "translation", etc.
    let direction: String?     // "ltr", "rtl", or nil
}
