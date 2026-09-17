import Foundation

enum Endpoint: Sendable {
    case surahList
    case surahListFallback
    case surahDetail(number: Int, edition: String)
    case juz(number: Int, edition: String)
    case audioEditions
    case translationEditions
    case editionsByLanguage(code: String)
    case search(keyword: String, edition: String)
    case ayahAudio(bitrate: Int = 128, edition: String, ayah: Int)
    case surahAudio(bitrate: Int = 128, edition: String, surah: Int)
    
    var url: URL {
        let baseURLString = "https://api.alquran.cloud/v1"
        let cdnBaseURLString = "https://cdn.islamic.network/quran"
        
        switch self {
        case .surahList:
            return URL(string: "\(baseURLString)/surah")!
        case .surahListFallback:
            return URL(string: "https://quranapi.pages.dev/api/surah.json")!
        case .surahDetail(let number, let edition):
            return URL(string: "\(baseURLString)/surah/\(number)/\(edition)")!
        case .juz(let number, let edition):
            return URL(string: "\(baseURLString)/juz/\(number)/\(edition)")!
        case .audioEditions:
            return URL(string: "\(baseURLString)/edition/format/audio")!
        case .translationEditions:
            return URL(string: "\(baseURLString)/edition/type/translation")!
        case .editionsByLanguage(let code):
            return URL(string: "\(baseURLString)/edition/language/\(code)")!
        case .search(let keyword, let edition):
            let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? keyword
            return URL(string: "\(baseURLString)/search/\(encodedKeyword)/all/\(edition)")!
        case .ayahAudio(let bitrate, let edition, let ayah):
            return URL(string: "\(cdnBaseURLString)/audio/\(bitrate)/\(edition)/\(ayah).mp3")!
        case .surahAudio(let bitrate, let edition, let surah):
            return URL(string: "\(cdnBaseURLString)/audio/\(bitrate)/\(edition)/\(surah).mp3")!
        }
    }

    var timeoutInterval: TimeInterval {
        switch self {
        case .surahList, .surahListFallback:
            return 12
        default:
            return 30
        }
    }
}
