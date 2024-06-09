import Foundation
import SwiftData

@Model
final class SettingsProfile {
    var createdTime: Date
    var name: String
    var supportLanguages: [SearchLanguage]
    var useLocationInSearchQuery: Bool
    var searchEngine: SearchEngine
    var searchContent: SearchContent
    var fromTranslateLanguage: TranslateLanguage
    var toTranslateLanguage: TranslateLanguage
    
    init(
        createdTime: Date,
        name: String,
        supportLanguages: [SearchLanguage],
        useLocationInSearchQuery: Bool,
        searchEngine: SearchEngine,
        searchContent: SearchContent,
        fromTranslateLanguage: TranslateLanguage,
        toTranslateLanguage: TranslateLanguage
    ) {
        self.createdTime = createdTime
        self.name = name
        self.supportLanguages = supportLanguages
        self.useLocationInSearchQuery = useLocationInSearchQuery
        self.searchEngine = searchEngine
        self.searchContent = searchContent
        self.fromTranslateLanguage = fromTranslateLanguage
        self.toTranslateLanguage = toTranslateLanguage
    }
}

func createDefaultSettingsProfile() -> SettingsProfile {
    return SettingsProfile(
        createdTime: Date.now,
        name: "Settings Profile",
        supportLanguages: [.englishUS],
        useLocationInSearchQuery: false,
        searchEngine: .google,
        searchContent:.images,
        fromTranslateLanguage: .english,
        toTranslateLanguage:.chineseSimplified
    )
}

func saveSettingsProfileId(id: PersistentIdentifier) {
    let data = try! JSONEncoder().encode(id)
    UserDefaults.standard.setValue(data, forKey: "settingsProfileId")
}

func loadSettingsProfileId() -> PersistentIdentifier? {
    if let data = UserDefaults.standard.data(forKey: "settingsProfileId") {
        return try! JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }
    
    return nil
}
