import Foundation

enum SearchLanguage: String, Codable, CaseIterable {
    case englishUS = "en-US"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case frenchFrance = "fr-FR"
    case germanGermany = "de-DE"
    case italianItaly = "it-IT"
    case japaneseJapan = "ja-JP"
    case koreanSouthKorea = "ko-KR"
    case portugueseBrazil = "pt-BR"
    case russianRussia = "ru-RU"
    case spanishSpain = "es-ES"
    case thaiThailand = "th-TH"
    case ukrainianUkraine = "uk-UA"
    case vietnameseVietnam = "vi-VT"
    
    var displayName: String {
        switch self {
        case .englishUS: return "English"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .chineseTraditional: return "Chinese (Traditional)"
        case .frenchFrance: return "French"
        case .germanGermany: return "German"
        case .italianItaly: return "Italian"
        case .japaneseJapan: return "Japanese"
        case .koreanSouthKorea: return "Korean"
        case .portugueseBrazil: return "Portuguese"
        case .russianRussia: return "Russian"
        case .spanishSpain: return "Spanish"
        case .thaiThailand: return "Thai"
        case .ukrainianUkraine: return "Ukrainian"
        case .vietnameseVietnam: return "Vietnamese"
        }
    }
}

func saveCameraSearchLanguages(languages: [SearchLanguage]) {
    let data = try? JSONEncoder().encode(languages)
    UserDefaults.standard.set(data, forKey: "selectedCameraSearchLanguages")
}

func loadCameraSearchLanguages() -> [SearchLanguage] {
    let userDefaults = UserDefaults.standard
    if userDefaults.object(forKey: "selectedCameraSearchLanguages") == nil {
        return [
            .chineseSimplified,
            .englishUS,
        ]
    } else {
        if let data = userDefaults.data(forKey: "selectedCameraSearchLanguages"),
           let languages = try? JSONDecoder().decode([SearchLanguage].self, from: data) {
            return languages
        }
        return [
            .chineseSimplified,
            .englishUS,
        ]
    }
}
