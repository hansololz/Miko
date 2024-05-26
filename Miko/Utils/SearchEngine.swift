import Foundation

enum SearchEngineOption: String, CaseIterable {
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

let searchEngineDirectory: [SearchEngineOption: [SearchContentOption: (String) -> String]] = [
    .google: [
        .all:       { searchText in "https://www.google.com/search?q=\(searchText)" },
        .images:    { searchText in "https://www.google.com/search?q=\(searchText)&tbm=isch" },
        .videos:    { searchText in "https://www.google.com/search?q=\(searchText)&tbm=vid" },
        .news:      { searchText in "https://www.google.com/search?q=\(searchText)&tbm=nws" },
        .shopping:  { searchText in "https://www.google.com/search?q=\(searchText)&tbm=shop" },
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
        .images:    { searchText in "https://duckduckgo.com?q=\(searchText)&iax=images&ia=images" },
        .videos:    { searchText in "https://duckduckgo.com?q=\(searchText)&iax=videos&ia=videos" },
        .news:      { searchText in "https://duckduckgo.com?q=\(searchText)&iar=news&ia=news" },
        .shopping:  { searchText in "https://duckduckgo.com?q=\(searchText)&iar=shopping&ia=shopping" },
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
