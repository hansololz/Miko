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

func getSearchUrl(engine: SearchEngineOption, content: SearchContentOption, searchText: String) -> String {
    if engine == .google {
        
    } else if engine == .bing {
        
    } else if engine == .duckDuckGo {
        
    }
    
    return "https://www.google.com/search?tbm=isch&q=\(searchText)"
}
