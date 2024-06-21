import Foundation
import SwiftData

@Model
final class SearchConfiguration {
    var createdTime: Date
    var modifiedTime: Date
    var name: String
    var supportLanguages: [SearchLanguage]
    var useLocationInSearchQuery: Bool
    var searchEngine: SearchEngine
    var searchContent: SearchContent
    var fromTranslateLanguage: TranslateLanguage
    var toTranslateLanguage: TranslateLanguage
    
    init(
        createdTime: Date,
        modifiedTime: Date,
        name: String,
        supportLanguages: [SearchLanguage],
        useLocationInSearchQuery: Bool,
        searchEngine: SearchEngine,
        searchContent: SearchContent,
        fromTranslateLanguage: TranslateLanguage,
        toTranslateLanguage: TranslateLanguage
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

func createDefaultSearchConfigs() -> [SearchConfiguration] {
    return [
        SearchConfiguration(
            createdTime: Date.now,
            modifiedTime: Calendar.current.date(byAdding: .second, value: 3, to: Date.now) ?? Date.now,
            name: "All",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .all,
            fromTranslateLanguage: .english,
            toTranslateLanguage: .chineseSimplified
        ),
        SearchConfiguration(
            createdTime: Date.now,
            modifiedTime: Calendar.current.date(byAdding: .second, value: 2, to: Date.now) ?? Date.now,
            name: "Images",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .images,
            fromTranslateLanguage: .english,
            toTranslateLanguage: .chineseSimplified
        ),
        SearchConfiguration(
            createdTime: Date.now,
            modifiedTime: Calendar.current.date(byAdding: .second, value: 1, to: Date.now) ?? Date.now,
            name: "Tranlsate EN to CH",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .translate,
            fromTranslateLanguage: .english,
            toTranslateLanguage: .chineseSimplified
        ),
        SearchConfiguration(
            createdTime: Date.now,
            modifiedTime: Date.now,
            name: "Shopping",
            supportLanguages: [.englishUS, .chineseSimplified],
            useLocationInSearchQuery: false,
            searchEngine: .google,
            searchContent: .shopping,
            fromTranslateLanguage: .english,
            toTranslateLanguage: .chineseSimplified
        )
    ]
}

func createNewSearchConfig() -> SearchConfiguration {
    return SearchConfiguration(
        createdTime: Date.now,
        modifiedTime: Date.now,
        name: "New Config",
        supportLanguages: [.englishUS, .chineseSimplified],
        useLocationInSearchQuery: false,
        searchEngine: .google,
        searchContent:.images,
        fromTranslateLanguage: .english,
        toTranslateLanguage: .chineseSimplified
    )
}

func saveSelectedSearchConfigId(id: PersistentIdentifier) {
    let data = try! JSONEncoder().encode(id)
    UserDefaults.standard.setValue(data, forKey: "SearchConfigurationId")
}

func loadSelectedSearchConfigId() -> PersistentIdentifier? {
    if let data = UserDefaults.standard.data(forKey: "SearchConfigurationId") {
        return try! JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }
    
    return nil
}
