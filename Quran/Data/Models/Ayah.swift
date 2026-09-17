import Foundation

struct Ayah: Identifiable, Hashable {
    var id: String { "\(surahNumber)-\(numberInSurah)" }
    let globalNumber: Int
    let surahNumber: Int
    let numberInSurah: Int
    let arabicText: String
    var translationText: String?
    let audioURL: URL?
    let juz: Int
    let page: Int
    let hasSajda: Bool
    
    /// The surah this ayah belongs to (useful in juz mode)
    var surahName: String?
    var surahEnglishName: String?
    
    init(from dto: AyahDTO, surahNumber: Int, surahName: String? = nil, surahEnglishName: String? = nil) {
        self.globalNumber = dto.number
        self.surahNumber = surahNumber
        self.numberInSurah = dto.numberInSurah
        self.arabicText = dto.text
        self.audioURL = dto.audio.flatMap { URL(string: $0) }
        self.juz = dto.juz
        self.page = dto.page
        self.hasSajda = dto.sajda.hasSajda
        self.surahName = surahName
        self.surahEnglishName = surahEnglishName
    }
    
    init(from dto: JuzAyahDTO) {
        self.globalNumber = dto.number
        self.surahNumber = dto.surah.number
        self.numberInSurah = dto.numberInSurah
        self.arabicText = dto.text
        self.audioURL = dto.audio.flatMap { URL(string: $0) }
        self.juz = dto.juz
        self.page = dto.page
        self.hasSajda = dto.sajda.hasSajda
        self.surahName = dto.surah.name
        self.surahEnglishName = dto.surah.englishName
    }
    
    init(from match: SearchMatchDTO) {
        self.globalNumber = match.number
        self.surahNumber = match.surah.number
        self.numberInSurah = match.numberInSurah
        
        // Search API might return either text or translation depending on what was searched
        // We map it to translation for now, or arabic if the language is arabic
        if match.edition.language == "ar" {
            self.arabicText = match.text
            self.translationText = nil
        } else {
            self.arabicText = "" // Or fetch the actual arabic text if needed
            self.translationText = match.text
        }
        
        self.audioURL = nil
        self.juz = match.juz
        self.page = match.page
        self.hasSajda = false
        self.surahName = match.surah.name
        self.surahEnglishName = match.surah.englishName
    }
}

