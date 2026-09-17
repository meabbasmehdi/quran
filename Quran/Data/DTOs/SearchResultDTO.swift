import Foundation

struct SearchResultDTO: Codable {
    let count: Int
    let matches: [SearchMatchDTO]
}

struct SearchMatchDTO: Codable {
    let number: Int
    let text: String
    let numberInSurah: Int
    let juz: Int
    let page: Int
    let surah: SurahDTO
    let edition: EditionDTO
}
