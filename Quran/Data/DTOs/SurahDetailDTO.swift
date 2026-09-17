import Foundation

struct SurahDetailDTO: Codable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let revelationType: String
    let numberOfAyahs: Int
    let ayahs: [AyahDTO]
    let edition: EditionDTO
}
