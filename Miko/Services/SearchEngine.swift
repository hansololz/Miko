import Foundation

enum SearchEngine: String, Codable, CaseIterable {
    case google = "Google"
    case bing = "Bing"
    case brave = "Brave"
    case duckDuckGo = "DuckDuckGo"
    case baidu = "Baidu"
    case yandex = "Yandex"
    
    var displayName: String {
        return self.rawValue
    }
    
    static func from(_ value: String) -> SearchEngine? {
        return SearchEngine(rawValue: value)
    }
}

enum SearchContent: String, Codable, CaseIterable {
    case all = "All"
    case images = "Images"
    case videos = "Videos"
    case news = "News"
    case shopping = "Shopping"
    case translate = "Translate"
    
    var displayName: String {
        return self.rawValue
    }
    
    static func from(_ value: String) -> SearchContent? {
        return SearchContent(rawValue: value)
    }
}

enum TranslateLanguage: String, Codable, CaseIterable {
    case arabic = "ar"
    case bengali = "bn"
    case chineseSimplified = "zh-CN"
    case chineseTraditional = "zh-TW"
    case dutch = "nl"
    case english = "en"
    case french = "fr"
    case german = "de"
    case greek = "el"
    case gujarati = "gu"
    case hindi = "hi"
    case italian = "it"
    case japanese = "ja"
    case javanese = "jv"
    case korean = "ko"
    case marathi = "mr"
    case persian = "fa"
    case polish = "pl"
    case portuguese = "pt"
    case punjabi = "pa"
    case romanian = "ro"
    case russian = "ru"
    case spanish = "es"
    case tamil = "ta"
    case telugu = "te"
    case thai = "th"
    case turkish = "tr"
    case ukrainian = "uk"
    case urdu = "ur"
    case vietnamese = "vi"
    
    var displayName: String {
        switch self {
        case .arabic: return "Arabic"
        case .bengali: return "Bengali"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .chineseTraditional: return "Chinese (Traditional)"
        case .dutch: return "Dutch"
        case .english: return "English"
        case .french: return "French"
        case .german: return "German"
        case .greek: return "Greek"
        case .gujarati: return "Gujarati"
        case .hindi: return "Hindi"
        case .italian: return "Italian"
        case .japanese: return "Japanese"
        case .javanese: return "Javanese"
        case .korean: return "Korean"
        case .marathi: return "Marathi"
        case .persian: return "Persian"
        case .polish: return "Polish"
        case .portuguese: return "Portuguese"
        case .punjabi: return "Punjabi"
        case .romanian: return "Romanian"
        case .russian: return "Russian"
        case .spanish: return "Spanish"
        case .tamil: return "Tamil"
        case .telugu: return "Telugu"
        case .thai: return "Thai"
        case .turkish: return "Turkish"
        case .ukrainian: return "Ukrainian"
        case .urdu: return "Urdu"
        case .vietnamese: return "Vietnamese"
        }
    }
    
    static func from(_ value: String) -> TranslateLanguage? {
        return TranslateLanguage(rawValue: value)
    }
}

let searchEngineDirectory: [SearchEngine: [SearchContent: (String, TranslateLanguage?, TranslateLanguage?) -> String]] = [
    .google: [
        .all:       { searchText, from, to in "https://www.google.com/search?q=\(searchText)" },
        .images:    { searchText, from, to in "https://www.google.com/search?tbm=isch&q=\(searchText)" },
        .videos:    { searchText, from, to in "https://www.google.com/search?tbm=vid&q=\(searchText)" },
        .news:      { searchText, from, to in "https://www.google.com/search?tbm=nws&q=\(searchText)" },
        .shopping:  { searchText, from, to in "https://www.google.com/search?tbm=shop&q=\(searchText)" },
        .translate: { searchText, from, to in "https://translate.google.com/?sl=\((from ?? .english).rawValue)&tl=\((to ?? .chineseSimplified).rawValue)&op=translate&text=\(searchText)" },
    ],
    .brave: [
        .all:       { searchText, from, to in "https://search.brave.com/search?source=web&q=\(searchText)" },
        .images:    { searchText, from, to in "https://search.brave.com/images?q=\(searchText)" },
        .videos:    { searchText, from, to in "https://search.brave.com/videos?q=\(searchText)" },
        .news:      { searchText, from, to in "https://search.brave.com/news?q=\(searchText)" },
    ],
    .bing: [
        .all:       { searchText, from, to in "https://www.bing.com/search?q=\(searchText)" },
        .images:    { searchText, from, to in "https://www.bing.com/images/search?q=\(searchText)" },
        .videos:    { searchText, from, to in "https://www.bing.com/videos/search?q=\(searchText)" },
        .news:      { searchText, from, to in "https://www.bing.com/news/search?q=\(searchText)" },
        .shopping:  { searchText, from, to in "https://www.bing.com/shop/search?q=\(searchText)" },
    ],
    .duckDuckGo: [
        .all:       { searchText, from, to in "https://duckduckgo.com?q=\(searchText)" },
        .images:    { searchText, from, to in "https://duckduckgo.com?iax=images&ia=images&q=\(searchText)" },
        .videos:    { searchText, from, to in "https://duckduckgo.com?iax=videos&ia=videos&q=\(searchText)" },
        .news:      { searchText, from, to in "https://duckduckgo.com?iar=news&ia=news&q=\(searchText)" },
        .shopping:  { searchText, from, to in "https://duckduckgo.com?iar=shopping&ia=shopping&q=\(searchText)" },
    ],
    .baidu: [
        .all:       { searchText, from, to in "https://www.baidu.com/s?wd=\(searchText)" },
        .images:    { searchText, from, to in "https://image.baidu.com/search/index?tn=baiduimage&word=\(searchText)" },
    ],
    .yandex: [
        .all:       { searchText, from, to in "https://yandex.com/search?text=\(searchText)" },
        .images:    { searchText, from, to in "https://yandex.com/images/search?text=\(searchText)" },
        .videos:    { searchText, from, to in "https://yandex.com/video/search?text=\(searchText)" },
    ]
    
]

func getDefaultSearchUrl(searchText: String) -> URL? {
    return URL(string: "https://www.google.com/search?tbm=isch&q=\(searchText)")
}

func getSearchUrl(engine: SearchEngine, content: SearchContent, searchText: String, locationName: String, settingsProfile: SearchConfig) -> URL? {
    let query = if locationName.isEmpty {
        searchText
    } else {
        "\(searchText), \(locationName)"
    }
    
    if let contentOptions = searchEngineDirectory[engine] {
        if let searchMethod = contentOptions[content] {
            let urlString = searchMethod(query, settingsProfile.fromTranslateLanguage, settingsProfile.toTranslateLanguage)
            
            if let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return URL(string: encodedUrlString)
            }
        }
    }
    
    return nil
}

func getSearchUrl(
    engine: SearchEngine,
    content: SearchContent,
    searchText: String,
    locationName: String,
    from: TranslateLanguage?,
    to: TranslateLanguage?
) -> URL? {
    let query = if locationName.isEmpty {
        searchText
    } else {
        "\(searchText), \(locationName)"
    }
    
    let contentOptions = searchEngineDirectory[engine]
    if contentOptions == nil { return getDefaultSearchUrl(searchText: query) }
    let searchMethod = (contentOptions ?? [:])[content]
    let urlString = searchMethod!(query, from, to)
    
    if let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        return URL(string: encodedUrlString)
    }
    
    return nil
}

