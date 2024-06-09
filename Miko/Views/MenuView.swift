import SwiftData
import SwiftUI
import UIKit

struct MenuView: View {
    let locationName: String
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var searchText: String
    @Binding var translatePreference: TranslatePreference
    @State private var showCopiedMessage = false
    @State private var copiedMessageOpacity = 0.0
    @Binding var settingsProfile: SettingsProfile
    
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if searchText.isEmpty {
                        Section() {
                            Text("No text found for search query. Point the camera at text you want to look up.")
                        }
                    } else {
                        Section(header: Text("Query")) {
                            HStack(alignment: .top) {
                                Text("Text:").bold()
                                Text("\(searchText)")
                            }
                            
                            if !locationName.isEmpty {
                                HStack(alignment: .top) {
                                    Text("Location:").bold()
                                    Text("\(locationName)")
                                }
                            }
                            
                            HStack(alignment: .top) {
                                Text("Search Engine:").bold()
                                Text("\(settingsProfile.searchEngineOption.displayName)")
                            }
                            
                            HStack(alignment: .top) {
                                Text("Search Content:").bold()
                                Text("\(settingsProfile.searchContentOption.displayName)")
                            }
                            
                            if settingsProfile.searchContentOption == .translate {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Text("From:").bold()
                                        Text("\(translatePreference.from.displayName),")
                                    }
                                    HStack(alignment: .top) {
                                        Text("To:").bold()
                                        Text("\(translatePreference.to.displayName)")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Bookmarks")) {
                        if !searchText.isEmpty {
                            if findBookmark() != nil {
                                Button(action: {
                                    if let bookmark = findBookmark() {
                                        modelContext.delete(bookmark)
                                    }
                                }) {
                                    Label("Bookmark", systemImage: "bookmark.fill")
                                }
                            } else {
                                Button(action: {
                                    if settingsProfile.searchContentOption == .translate {
                                        modelContext.insert(
                                            Bookmark(
                                                createdTime: Date.now,
                                                searchText: searchText,
                                                locationName: locationName,
                                                searchEngine: settingsProfile.searchEngineOption,
                                                searchContent: settingsProfile.searchContentOption,
                                                translateFromLanguage: translatePreference.from,
                                                translateToLanguage: translatePreference.to
                                            )
                                        )
                                    } else {
                                        modelContext.insert(
                                            Bookmark(
                                                createdTime: Date.now,
                                                searchText: searchText,
                                                locationName: locationName,
                                                searchEngine: settingsProfile.searchEngineOption,
                                                searchContent: settingsProfile.searchContentOption,
                                                translateFromLanguage: nil,
                                                translateToLanguage: nil
                                            )
                                        )
                                    }
                                }) {
                                    Label("Bookmark", systemImage: "bookmark")
                                }
                            }
                        }
                        
                        NavigationLink {
                            BookmarksView()
                        } label: {
                            Label("View All Bookmarks", systemImage: "list.star")
                        }
                    }
                    
                    if !searchText.isEmpty {
                        Section(header: Text("Copy")) {
                            Button(action: {
                                copyToClipboard(text: searchText)
                            }) {
                                Label("Copy Text", systemImage: "doc.on.doc")
                            }
                            
                            if !locationName.isEmpty {
                                Button(action: {
                                    copyToClipboard(text: "\(searchText), \(locationName)")
                                }) {
                                    Label("Copy Text With Location", systemImage: "doc.on.doc")
                                }
                            }
                            
                            Button(action: {
                                if let url = getSearchUrl(
                                    engine: settingsProfile.searchEngineOption,
                                    content: settingsProfile.searchContentOption,
                                    searchText: searchText,
                                    locationName: "",
                                    settingsProfile: settingsProfile
                                ) {
                                    copyToClipboard(text: url.absoluteString)
                                }
                            }) {
                                Label("Copy URL", systemImage: "doc.on.doc")
                            }
                            
                            if !locationName.isEmpty {
                                Button(action: {
                                    if let url = getSearchUrl(
                                        engine: settingsProfile.searchEngineOption,
                                        content: settingsProfile.searchContentOption,
                                        searchText: searchText,
                                        locationName: locationName,
                                        settingsProfile: settingsProfile
                                    ) {
                                        copyToClipboard(text: url.absoluteString)
                                    }
                                }) {
                                    Label("Copy URL With Location", systemImage: "doc.on.doc")
                                }
                            }
                        }
                        
                        Section(header: Text("Share")) {
                            Button(action: {
                                shareText(text: searchText)
                            }) {
                                Label("Share Text", systemImage: "square.and.arrow.up")
                            }
                            
                            if !locationName.isEmpty {
                                Button(action: {
                                    shareText(text: "\(searchText), \(locationName)")
                                }) {
                                    Label("Share Text With Location", systemImage: "square.and.arrow.up")
                                }
                            }
                            
                            Button(action: {
                                if let url = getSearchUrl(
                                    engine: settingsProfile.searchEngineOption,
                                    content: settingsProfile.searchContentOption,
                                    searchText: searchText,
                                    locationName: "",
                                    settingsProfile: settingsProfile
                                ) {
                                    shareText(text: url.absoluteString)
                                }
                            }) {
                                Label("Share URL", systemImage: "square.and.arrow.up")
                            }
                            
                            if !locationName.isEmpty {
                                Button(action: {
                                    if let url = getSearchUrl(
                                        engine: settingsProfile.searchEngineOption,
                                        content: settingsProfile.searchContentOption,
                                        searchText: searchText,
                                        locationName: locationName,
                                        settingsProfile: settingsProfile
                                    ) {
                                        shareText(text: url.absoluteString)
                                    }
                                }) {
                                    Label("Share URL With Location", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                        
                        Section(header: Text("Browser")) {
                            Button(action: {
                                if let url = getSearchUrl(
                                    engine: settingsProfile.searchEngineOption,
                                    content: settingsProfile.searchContentOption,
                                    searchText: searchText,
                                    locationName: "",
                                    settingsProfile: settingsProfile
                                ) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label("Open In Browser", systemImage: "square.and.arrow.up")
                            }
                            
                            if !locationName.isEmpty {
                                Button(action: {
                                    if let url = getSearchUrl(
                                        engine: settingsProfile.searchEngineOption,
                                        content: settingsProfile.searchContentOption,
                                        searchText: searchText,
                                        locationName: locationName,
                                        settingsProfile: settingsProfile
                                    ) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Label("Open In Browser With Location", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Search Query")
                .navigationBarItems(leading: Button("Done") {
                    selectSheetAnchor = restSheetAnchor
                })
                
                VStack {
                    Spacer()
                    Text("Text copied to clipboard")
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                        .opacity(copiedMessageOpacity)
                        .animation(.easeInOut, value: copiedMessageOpacity)
                }
                .animation(.easeInOut, value: showCopiedMessage)
            }
        }
    }
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        showCopiedMessage = true
        withAnimation {
            copiedMessageOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedMessageOpacity = 0.0
            }
        }
    }
    
    private func shareText(text: String) {
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            var viewController = windowScene.windows.first?.rootViewController
            
            while let presentedViewController = viewController?.presentedViewController {
                viewController = presentedViewController
            }
            
            viewController?.present(activityController, animated: true, completion: nil)
        }
    }
    
    private func findBookmark() -> Bookmark? {
        return bookmarks.first(where: {
            if $0.searchContent == .translate {
                $0.searchText == searchText &&
                $0.locationName == locationName &&
                $0.searchEngine == settingsProfile.searchEngineOption &&
                $0.searchContent == settingsProfile.searchContentOption &&
                $0.translateFromLanguage == translatePreference.from &&
                $0.translateToLanguage == translatePreference.to
            } else {
                $0.searchText == searchText &&
                $0.locationName == locationName &&
                $0.searchEngine == settingsProfile.searchEngineOption &&
                $0.searchContent == settingsProfile.searchContentOption
            }
        })
    }
}

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bookmark.createdTime, order: .reverse) private var bookmarks: [Bookmark]
    
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                NavigationLink {
                    BookmarkView(
                        searchText: bookmark.searchText,
                        locationName: bookmark.locationName,
                        searchEngineOption: bookmark.searchEngine,
                        searchContentOption: bookmark.searchContent,
                        createdTime: bookmark.createdTime,
                        from: bookmark.translateFromLanguage,
                        to: bookmark.translateToLanguage
                    )
                } label: {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text("Text:").bold()
                            Text("\(bookmark.searchText)")
                        }
                        if !bookmark.locationName.isEmpty {
                            HStack(alignment: .top) {
                                Text("Location:").bold()
                                Text("\(bookmark.locationName)")
                            }
                        }
                        HStack(alignment: .top) {
                            Text("Search Engine:").bold()
                            Text("\(bookmark.searchEngine.displayName)")
                        }
                        HStack(alignment: .top) {
                            Text("Search Content:").bold()
                            Text("\(bookmark.searchContent.displayName)")
                        }
                        if bookmark.searchContent == .translate {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("From:").bold()
                                    Text((bookmark.translateFromLanguage ?? .english) .displayName)
                                }
                                HStack(alignment: .top) {
                                    Text("To:").bold()
                                    Text((bookmark.translateToLanguage ?? .chineseSimplified).displayName)
                                }
                            }
                        }
                        HStack(alignment: .top) {
                            Text("Created Time:").bold()
                            Text(bookmark.createdTime, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Bookmarks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(bookmarks[index])
            }
        }
    }
}

struct BookmarkView: View {
    var searchText: String
    var locationName: String
    var searchEngineOption: SearchEngineOption
    var searchContentOption: SearchContentOption
    var createdTime: Date
    //    var translatePreference: TranslatePreference
    var from: TranslateLanguage?
    var to: TranslateLanguage?
    @State private var showCopiedMessage = false
    @State private var copiedMessageOpacity = 0.0
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("Query")) {
                    HStack(alignment: .top) {
                        Text("Text:").bold()
                        Text("\(searchText)")
                    }
                    
                    if !locationName.isEmpty {
                        HStack(alignment: .top) {
                            Text("Location:").bold()
                            Text("\(locationName)")
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("Search Engine:").bold()
                        Text("\(searchEngineOption.displayName)")
                    }
                    
                    HStack(alignment: .top) {
                        Text("Search Content:").bold()
                        Text("\(searchContentOption.displayName)")
                    }
                    
                    if searchContentOption == .translate {
                        if let fromString = from?.displayName, let toString = to?.displayName {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("From:").bold()
                                    Text(fromString)
                                }
                                HStack(alignment: .top) {
                                    Text("To:").bold()
                                    Text(toString)
                                }
                            }
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("Created Time:").bold()
                        Text(createdTime, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                
                Section(header: Text("Copy")) {
                    Button(action: {
                        copyToClipboard(text: searchText)
                    }) {
                        Label("Copy Text", systemImage: "doc.on.doc")
                    }
                    
                    if !locationName.isEmpty {
                        Button(action: {
                            copyToClipboard(text: "\(searchText), \(locationName)")
                        }) {
                            Label("Copy Text With Location", systemImage: "doc.on.doc")
                        }
                    }
                    
                    Button(action: {
                        if let url = getSearchUrl(
                            engine: searchEngineOption,
                            content: searchContentOption,
                            searchText: searchText,
                            locationName: "",
                            from: from,
                            to: to
                        ) {
                            copyToClipboard(text: url.absoluteString)
                        }
                    }) {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }
                    
                    if !locationName.isEmpty {
                        Button(action: {
                            if let url = getSearchUrl(
                                engine: searchEngineOption,
                                content: searchContentOption,
                                searchText: searchText,
                                locationName: locationName,
                                from: from,
                                to: to
                            ) {
                                copyToClipboard(text: url.absoluteString)
                            }
                        }) {
                            Label("Copy URL With Location", systemImage: "doc.on.doc")
                        }
                    }
                }
                
                Section(header: Text("Share")) {
                    Button(action: {
                        shareText(text: searchText)
                    }) {
                        Label("Share Text", systemImage: "square.and.arrow.up")
                    }
                    
                    if !locationName.isEmpty {
                        Button(action: {
                            shareText(text: "\(searchText), \(locationName)")
                        }) {
                            Label("Share Text With Location", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    Button(action: {
                        if let url = getSearchUrl(
                            engine: searchEngineOption,
                            content: searchContentOption,
                            searchText: searchText,
                            locationName: "",
                            from: from,
                            to: to
                        ) {
                            shareText(text: url.absoluteString)
                        }
                    }) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                    }
                    
                    if !locationName.isEmpty {
                        Button(action: {
                            if let url = getSearchUrl(
                                engine: searchEngineOption,
                                content: searchContentOption,
                                searchText: searchText,
                                locationName: locationName,
                                from: from,
                                to: to
                            ) {
                                shareText(text: url.absoluteString)
                            }
                        }) {
                            Label("Share URL With Location", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
                Section(header: Text("Browser")) {
                    Button(action: {
                        if let url = getSearchUrl(
                            engine: searchEngineOption,
                            content: searchContentOption,
                            searchText: searchText,
                            locationName: "",
                            from: from,
                            to: to
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Open In Browser", systemImage: "square.and.arrow.up")
                    }
                    
                    if !locationName.isEmpty {
                        Button(action: {
                            if let url = getSearchUrl(
                                engine: searchEngineOption,
                                content: searchContentOption,
                                searchText: searchText,
                                locationName: locationName,
                                from: from,
                                to: to
                            ) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("Open In Browser With Location", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .navigationTitle("Bookmark")
            
            VStack {
                Spacer()
                Text("Text copied to clipboard")
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .opacity(copiedMessageOpacity)
                    .animation(.easeInOut, value: copiedMessageOpacity)
            }
            .animation(.easeInOut, value: showCopiedMessage)
        }
    }
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        showCopiedMessage = true
        withAnimation {
            copiedMessageOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedMessageOpacity = 0.0
            }
        }
    }
    
    private func shareText(text: String) {
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            var viewController = windowScene.windows.first?.rootViewController
            
            while let presentedViewController = viewController?.presentedViewController {
                viewController = presentedViewController
            }
            
            viewController?.present(activityController, animated: true, completion: nil)
        }
    }
}
