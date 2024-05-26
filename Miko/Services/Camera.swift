import Foundation

enum SearchLanguage: String, Codable, CaseIterable {
    case englishUS = "en-US"
    case frenchFrance = "fr-FR"
    case italianItaly = "it-IT"
    case germanGermany = "de-DE"
    case spanishSpain = "es-ES"
    case portugueseBrazil = "pt-BR"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case cantoneseSimplified = "yue-Hans"
    case cantoneseTraditional = "yue-Hant"
    case koreanSouthKorea = "ko-KR"
    case japaneseJapan = "ja-JP"
    case russianRussia = "ru-RU"
    case ukrainianUkraine = "uk-UA"
    case thaiThailand = "th-TH"
    case vietnameseVietnam = "vi-VT"
    
    var displayName: String {
        switch self {
        case .englishUS: return "English (United States)"
        case .frenchFrance: return "French (France)"
        case .italianItaly: return "Italian (Italy)"
        case .germanGermany: return "German (Germany)"
        case .spanishSpain: return "Spanish (Spain)"
        case .portugueseBrazil: return "Portuguese (Brazil)"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .chineseTraditional: return "Chinese (Traditional)"
        case .cantoneseSimplified: return "Cantonese (Simplified)"
        case .cantoneseTraditional: return "Cantonese (Traditional)"
        case .koreanSouthKorea: return "Korean (South Korea)"
        case .japaneseJapan: return "Japanese (Japan)"
        case .russianRussia: return "Russian (Russia)"
        case .ukrainianUkraine: return "Ukrainian (Ukraine)"
        case .thaiThailand: return "Thai (Thailand)"
        case .vietnameseVietnam: return "Vietnamese (Vietnam)"
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
            .englishUS,
            .chineseSimplified,
            .japaneseJapan
        ]
    } else {
        if let data = userDefaults.data(forKey: "selectedCameraSearchLanguages"),
           let languages = try? JSONDecoder().decode([SearchLanguage].self, from: data) {
            return languages
        }
        return [
            .englishUS,
            .chineseSimplified,
            .japaneseJapan
        ]
    }
}
