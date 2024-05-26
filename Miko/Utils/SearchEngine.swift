import Foundation

enum SearchEngineOption: String, CaseIterable {
    case google = "Google"
    case bing = "Bing"
    case duckDuckGo = "DuckDuckGo"
    
    var displayName: String {
        return self.rawValue
    }
    
    static func from(_ value: String) -> SearchEngineOption? {
        return SearchEngineOption(rawValue: value)
    }
}

enum SearchContentOption: String, CaseIterable {
    case all = "All"
    case images = "Images"
    case videos = "Videos"
    case news = "News"
    case shopping = "Shopping"
    
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

private let googleBaseUrl = "https://www.google.com/search"
private let bingBaseUrl = "https://www.bing.com"
private let duckDuckGoBaseUrl = "https://duckduckgo.com"

let searchEngineDirectory: [SearchEngineOption: [SearchContentOption: (String) -> String]] = [
    .google: [
        .all:       { searchText in "\(googleBaseUrl)?q=\(searchText)" },
        .images:    { searchText in "\(googleBaseUrl)?q=\(searchText)&tbm=isch" },
        .videos:    { searchText in "\(googleBaseUrl)?q=\(searchText)&tbm=vid" },
        .news:      { searchText in "\(googleBaseUrl)?q=\(searchText)&tbm=nws" },
        .shopping:  { searchText in "\(googleBaseUrl)?q=\(searchText)&tbm=shop" },
    ],
    .bing: [
        .all:       { searchText in "\(bingBaseUrl)/search?q=\(searchText)" },
        .images:    { searchText in "\(bingBaseUrl)/images/search?q=\(searchText)" },
        .videos:    { searchText in "\(bingBaseUrl)/videos/search?q=\(searchText)" },
        .news:      { searchText in "\(bingBaseUrl)/news/search?q=\(searchText)" },
        .shopping:  { searchText in "\(bingBaseUrl)/shop/search?q=\(searchText)" },
    ],
    .duckDuckGo: [
        .all:       { searchText in "\(duckDuckGoBaseUrl)?q=\(searchText)" },
        .images:    { searchText in "\(duckDuckGoBaseUrl)?q=\(searchText)&iax=images&ia=images" },
        .videos:    { searchText in "\(duckDuckGoBaseUrl)?q=\(searchText)&iax=videos&ia=videos" },
        .news:      { searchText in "\(duckDuckGoBaseUrl)?q=\(searchText)&iar=news&ia=news" },
        .shopping:  { searchText in "\(duckDuckGoBaseUrl)?q=\(searchText)&iar=shopping&ia=shopping" },
    ]
]

func getDefaultSearchUrl(searchText: String) -> String  {
    return "https://www.google.com/search?tbm=isch&q=\(searchText)"
}

func getSearchUrl(engine: SearchEngineOption, content: SearchContentOption, searchText: String) -> String {
    let contentOptions = searchEngineDirectory[engine]
    if contentOptions == nil { return getDefaultSearchUrl(searchText: searchText) }
    let searchMethod = (contentOptions ?? [:])[content]
    if searchMethod == nil {
        return getDefaultSearchUrl(searchText: searchText)
    } else {
        return searchMethod!(searchText)
    }
}
