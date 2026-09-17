import Foundation

struct Edition: Identifiable, Hashable {
    var id: String { identifier }
    let identifier: String
    let language: String
    let name: String
    let englishName: String
    let format: EditionFormat
    let type: EditionType
    let direction: TextDirection
    
    enum EditionFormat: String, Hashable {
        case audio, text
    }
    
    enum EditionType: String, Hashable {
        case versebyverse, translation
        case other
    }
    
    enum TextDirection: String, Hashable {
        case ltr, rtl
    }
    
    init(from dto: EditionDTO) {
        self.identifier = dto.identifier
        self.language = dto.language
        self.name = dto.name
        self.englishName = dto.englishName
        self.format = EditionFormat(rawValue: dto.format) ?? .text
        self.type = EditionType(rawValue: dto.type) ?? .other
        self.direction = TextDirection(rawValue: dto.direction ?? "ltr") ?? .ltr
    }
}
