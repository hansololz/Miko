import Foundation
import SwiftData

@Model
final class SettingsProfile {
    var createdTime: Date
    var supportLanguages: [SearchLanguage]
    var useLocationInSearchQuery: Bool
    var searchEngineOption: SearchEngineOption
    var searchContentOption: SearchContentOption
    var fromTranslateLanguage: TranslateLanguage
    var toTranslateLanguage: TranslateLanguage
    
    init(
        createdTime: Date,
        supportLanguages: [SearchLanguage],
        useLocationInSearchQuery: Bool,
        searchEngineOption: SearchEngineOption,
        searchContentOption: SearchContentOption,
        fromTranslateLanguage: TranslateLanguage,
        toTranslateLanguage: TranslateLanguage
    ) {
        self.createdTime = createdTime
        self.supportLanguages = supportLanguages
        self.useLocationInSearchQuery = useLocationInSearchQuery
        self.searchEngineOption = searchEngineOption
        self.searchContentOption = searchContentOption
        self.fromTranslateLanguage = fromTranslateLanguage
        self.toTranslateLanguage = toTranslateLanguage
    }
}

func createDefaultSettingsProfile() -> SettingsProfile {
    return SettingsProfile(
        createdTime: Date.now,
        supportLanguages: [SearchLanguage.englishUS],
        useLocationInSearchQuery: false,
        searchEngineOption: .google,
        searchContentOption:.images,
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
