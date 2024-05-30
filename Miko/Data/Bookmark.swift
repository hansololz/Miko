import Foundation
import SwiftData

@Model
final class Bookmark {
    var createdTime: Date
    var searchText: String
    var locationName: String
    var searchEngine: SearchEngineOption
    var searchContent: SearchContentOption

    init(
        createdTime: Date,
        searchText: String,
        locationName: String,
        searchEngine: SearchEngineOption,
        searchContent: SearchContentOption
    ) {
        self.createdTime = createdTime
        self.searchText = searchText
        self.locationName = locationName
        self.searchEngine = searchEngine
        self.searchContent = searchContent
    }
}
