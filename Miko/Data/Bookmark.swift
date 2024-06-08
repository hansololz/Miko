import Foundation
import SwiftData

@Model
final class Bookmark {
    var createdTime: Date
    var searchText: String
    var locationName: String
    var searchEngine: SearchEngineOption
    var searchContent: SearchContentOption
    var translateFromLanguage: TranslateLanguage? // Not part of inital schema
    var translateToLanguage: TranslateLanguage? // Not part of inital schema

    init(
        createdTime: Date,
        searchText: String,
        locationName: String,
        searchEngine: SearchEngineOption,
        searchContent: SearchContentOption,
        translateFromLanguage: TranslateLanguage? = nil,
        translateToLanguage: TranslateLanguage? = nil
    ) {
        self.createdTime = createdTime
        self.searchText = searchText
        self.locationName = locationName
        self.searchEngine = searchEngine
        self.searchContent = searchContent
        self.translateFromLanguage = translateFromLanguage
        self.translateToLanguage = translateToLanguage
    }
}
