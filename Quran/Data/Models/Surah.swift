import Foundation

struct Surah: Identifiable, Hashable {
    let id: Int          // same as number
    let number: Int
    let arabicName: String
    let englishName: String
    let englishTranslation: String
    let ayahCount: Int
    let revelationType: RevelationType
    
    enum RevelationType: String, Hashable {
        case meccan = "Meccan"
        case medinan = "Medinan"
    }
    
    init(from dto: SurahDTO) {
        self.id = dto.number
        self.number = dto.number
        self.arabicName = dto.name
        self.englishName = dto.englishName
        self.englishTranslation = dto.englishNameTranslation
        self.ayahCount = dto.numberOfAyahs
        self.revelationType = RevelationType(rawValue: dto.revelationType) ?? .meccan
    }
}
