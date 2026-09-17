import Foundation

struct SurahDTO: Codable, Hashable {
    let number: Int
    let name: String           // Arabic name with diacritics
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String // "Meccan" or "Medinan"
}

/// Response shape used by the lightweight static Surah-list provider.
struct FallbackSurahDTO: Decodable {
    let surahName: String
    let surahNameArabic: String
    let surahNameTranslation: String
    let revelationPlace: String
    let totalAyah: Int

    func asSurahDTO(number: Int) -> SurahDTO {
        SurahDTO(
            number: number,
            name: surahNameArabic,
            englishName: surahName,
            englishNameTranslation: surahNameTranslation,
            numberOfAyahs: totalAyah,
            revelationType: revelationPlace.lowercased() == "mecca" ? "Meccan" : "Medinan"
        )
    }
}
