import Foundation

enum SearchEngineOption: String, Codable, CaseIterable {
    case google = "Google"
    case bing = "Bing"
    case brave = "Brave"
    case duckDuckGo = "DuckDuckGo"
    case baidu = "Baidu"
    case yandex = "Yandex"
    
    var displayName: String {
        return self.rawValue
    }
    
    static func from(_ value: String) -> SearchEngineOption? {
        return SearchEngineOption(rawValue: value)
    }
}

enum SearchContentOption: String, Codable, CaseIterable {
    case all = "All"
    case images = "Images"
    case videos = "Videos"
    case news = "News"
    case shopping = "Shopping"
    case translate = "Translate"
    
    var displayName: String {
        return self.rawValue
    }
    
    static func from(_ value: String) -> SearchContentOption? {
        return SearchContentOption(rawValue: value)
    }
}

func saveSearchEnginePreference(option: SearchEngineOption) {
    UserDefaults.standard.set(option.rawValue, forKey: "searchEngineOption")
}

func loadSearchEnginePreference() -> SearchEngineOption {
    if let savedOption = UserDefaults.standard.string(forKey: "searchEngineOption"),
       let option = SearchEngineOption.from(savedOption) {
        return option
    } else {
        return .google
    }
}

func saveSearchContentPreference(option: SearchContentOption) {
    UserDefaults.standard.set(option.rawValue, forKey: "searchContentOption")
}

func loadSearchContentPreference() -> SearchContentOption {
    if let savedOption = UserDefaults.standard.string(forKey: "searchContentOption"),
       let option = SearchContentOption.from(savedOption) {
        return option
    } else {
        return .images
    }
}

let searchEngineDirectory: [SearchEngineOption: [SearchContentOption: (String) -> String]] = [
    .google: [
        .all:       { searchText in "https://www.google.com/search?q=\(searchText)" },
        .images:    { searchText in "https://www.google.com/search?tbm=isch&q=\(searchText)" },
        .videos:    { searchText in "https://www.google.com/search?tbm=vid&q=\(searchText)" },
        .news:      { searchText in "https://www.google.com/search?tbm=nws&q=\(searchText)" },
        .shopping:  { searchText in "https://www.google.com/search?tbm=shop&q=\(searchText)" },
        .translate: { searchText in "https://translate.google.com/?sl=en&tl=zh-CN&text=\(searchText)" },
    ],
    .brave: [
        .all:       { searchText in "https://search.brave.com/search?source=web&q=\(searchText)" },
        .images:    { searchText in "https://search.brave.com/images?q=\(searchText)" },
        .videos:    { searchText in "https://search.brave.com/videos?q=\(searchText)" },
        .news:      { searchText in "https://search.brave.com/news?q=\(searchText)" },
    ],
    .bing: [
        .all:       { searchText in "https://www.bing.com/search?q=\(searchText)" },
        .images:    { searchText in "https://www.bing.com/images/search?q=\(searchText)" },
        .videos:    { searchText in "https://www.bing.com/videos/search?q=\(searchText)" },
        .news:      { searchText in "https://www.bing.com/news/search?q=\(searchText)" },
        .shopping:  { searchText in "https://www.bing.com/shop/search?q=\(searchText)" },
    ],
    .duckDuckGo: [
        .all:       { searchText in "https://duckduckgo.com?q=\(searchText)" },
        .images:    { searchText in "https://duckduckgo.com?iax=images&ia=images&q=\(searchText)" },
        .videos:    { searchText in "https://duckduckgo.com?iax=videos&ia=videos&q=\(searchText)" },
        .news:      { searchText in "https://duckduckgo.com?iar=news&ia=news&q=\(searchText)" },
        .shopping:  { searchText in "https://duckduckgo.com?iar=shopping&ia=shopping&q=\(searchText)" },
    ],
    .baidu: [
        .all:       { searchText in "https://www.baidu.com/s?wd=\(searchText)" },
        .images:    { searchText in "https://image.baidu.com/search/index?tn=baiduimage&word=\(searchText)" },
    ],
    .yandex: [
        .all:       { searchText in "https://yandex.com/search?text=\(searchText)" },
        .images:    { searchText in "https://yandex.com/images/search?text=\(searchText)" },
        .videos:    { searchText in "https://yandex.com/video/search?text=\(searchText)" },
    ]
    
]

func getDefaultSearchUrl(searchText: String) -> URL? {
    return URL(string: "https://www.google.com/search?tbm=isch&q=\(searchText)")
}

func getSearchUrl(engine: SearchEngineOption, content: SearchContentOption, searchText: String, locationName: String) -> URL? {
    let query = if locationName.isEmpty {
        searchText
    } else {
        "\(searchText), \(locationName)"
    }
    
    let contentOptions = searchEngineDirectory[engine]
    if contentOptions == nil { return getDefaultSearchUrl(searchText: query) }
    let searchMethod = (contentOptions ?? [:])[content]
    let urlString = searchMethod!(query)

    if let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        return URL(string: encodedUrlString)
    }
    
    return nil
}
