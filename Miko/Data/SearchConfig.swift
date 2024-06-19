import Foundation
import SwiftData

@Model
final class SearchConfig {
    var createdTime: Date
    var modifiedTime: Date
    var name: String
    var supportLanguages: [SearchLanguage]
    var useLocationInSearchQuery: Bool
    var searchEngine: SearchEngine
    var searchContent: SearchContent
    var fromTranslateLanguage: TranslateLanguage?
    var toTranslateLanguage: TranslateLanguage?
    
    init(
        createdTime: Date,
        modifiedTime: Date,
        name: String,
        supportLanguages: [SearchLanguage],
        useLocationInSearchQuery: Bool,
        searchEngine: SearchEngine,
        searchContent: SearchContent,
        fromTranslateLanguage: TranslateLanguage?,
        toTranslateLanguage: TranslateLanguage?
    ) {
        self.createdTime = createdTime
        self.modifiedTime = modifiedTime
        self.name = name
        self.supportLanguages = supportLanguages
        self.useLocationInSearchQuery = useLocationInSearchQuery
        self.searchEngine = searchEngine
        self.searchContent = searchContent
        self.fromTranslateLanguage = fromTranslateLanguage
        self.toTranslateLanguage = toTranslateLanguage
    }
}

func createDefaultSearchConfigs() -> [SearchConfig] {
    return [
        SearchConfig(
            createdTime: Date.now,
            modifiedTime: Calendar.current.date(byAdding: .second, value: 2, to: Date.now) ?? Date.now,
            name: "Images",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .images,
            fromTranslateLanguage: nil,
            toTranslateLanguage: nil
        ),
        SearchConfig(
            createdTime: Date.now,
            modifiedTime: Calendar.current.date(byAdding: .second, value: 1, to: Date.now) ?? Date.now,
            name: "Tranlsate",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .translate,
            fromTranslateLanguage: .english,
            toTranslateLanguage: .chineseSimplified
        ),
        SearchConfig(
            createdTime: Date.now,
            modifiedTime: Date.now,
            name: "Shopping",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .shopping,
            fromTranslateLanguage: nil,
            toTranslateLanguage: nil
        )
    ]
}

func createNewSearchConfig() -> SearchConfig {
    return SearchConfig(
        createdTime: Date.now,
        modifiedTime: Date.now,
        name: "New Config",
        supportLanguages: [.englishUS, .chineseSimplified],
        useLocationInSearchQuery: false,
        searchEngine: .google,
        searchContent:.images,
        fromTranslateLanguage: nil,
        toTranslateLanguage: nil
    )
}

func saveSelectedSearchConfigId(id: PersistentIdentifier) {
    let data = try! JSONEncoder().encode(id)
    UserDefaults.standard.setValue(data, forKey: "SearchConfigId")
}

func loadSelectedSearchConfigId() -> PersistentIdentifier? {
    if let data = UserDefaults.standard.data(forKey: "SearchConfigId") {
        return try! JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }
    
    return nil
}
