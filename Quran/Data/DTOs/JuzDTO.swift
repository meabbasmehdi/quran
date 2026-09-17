import Foundation

struct JuzDTO: Codable {
    let number: Int
    let ayahs: [JuzAyahDTO]
    let edition: EditionDTO
    let surahs: [String: SurahDTO]  // String keys like "1", "2"
}

struct JuzAyahDTO: Codable {
    let number: Int
    let audio: String?
    let audioSecondary: [String]?
    let text: String
    let numberInSurah: Int
    let juz: Int
    let manzil: Int
    let page: Int
    let ruku: Int
    let hizbQuarter: Int
    let sajda: SajdaValue
    let surah: SurahDTO      // Embedded surah info per ayah
}
