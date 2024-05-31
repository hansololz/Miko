import SwiftData
import SwiftUI
import UIKit

struct MenuView: View {
    let locationName: String
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var searchText: String
    @Binding var searchEngineOption: SearchEngineOption
    @Binding var searchContentOption: SearchContentOption
    @State private var showCopiedMessage = false
    @State private var copiedMessageOpacity = 0.0
    
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Query")) {
                        HStack {
                            Text("Text:").bold()
                            Text("\(searchText)")
                        }
                        
                        if !locationName.isEmpty {
                            HStack {
                                Text("Location:").bold()
                                Text("\(locationName)")
                            }
                        }
                        
                        HStack {
                            Text("Search Engine:").bold()
                            Text("\(searchEngineOption.displayName)")
                        }
                        
                        HStack {
                            Text("Search Content:").bold()
                            Text("\(searchContentOption.displayName)")
                        }
                    }
                    
                    Section(header: Text("Bookmark")) {
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
                                modelContext.insert(
                                    Bookmark(
                                        createdTime: Date.now,
                                        searchText: searchText,
                                        locationName: locationName,
                                        searchEngine: searchEngineOption,
                                        searchContent: searchContentOption
                                    )
                                )
                            }) {
                                Label("Bookmark", systemImage: "bookmark")
                            }
                        }
                        
                        NavigationLink {
                            BookmarksView()
                        } label: {
                            Label("View All Bookmarks", systemImage: "bookmark")
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
                            let url = getSearchUrl(
                                engine: searchEngineOption,
                                content: searchContentOption,
                                searchText: searchText,
                                locationName: ""
                            )
                            copyToClipboard(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                        }) {
                            Label("Copy URL", systemImage: "doc.on.doc")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
                                let url = getSearchUrl(
                                    engine: searchEngineOption,
                                    content: searchContentOption,
                                    searchText: searchText,
                                    locationName: locationName
                                )
                                copyToClipboard(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
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
                            let url = getSearchUrl(
                                engine: searchEngineOption,
                                content: searchContentOption,
                                searchText: searchText,
                                locationName: ""
                            )
                            shareText(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                        }) {
                            Label("Share URL", systemImage: "square.and.arrow.up")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
                                let url = getSearchUrl(
                                    engine: searchEngineOption,
                                    content: searchContentOption,
                                    searchText: searchText,
                                    locationName: locationName
                                )
                                shareText(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                            }) {
                                Label("Share URL With Location", systemImage: "square.and.arrow.up")
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
            $0.searchText == searchText &&
            $0.locationName == locationName &&
            $0.searchEngine == searchEngineOption &&
            $0.searchContent == searchContentOption
        })
    }
}

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]

    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                NavigationLink {
                    Text("Item at \(bookmark.createdTime, format: Date.FormatStyle(date: .numeric, time: .standard))")
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Text:").bold()
                            Text("\(bookmark.searchText)")
                        }
                        if !bookmark.locationName.isEmpty {
                            HStack {
                                Text("Location:").bold()
                                Text("\(bookmark.locationName)")
                            }
                        }
                        HStack {
                            Text("Search Engine:").bold()
                            Text("\(bookmark.searchEngine.displayName)")
                        }
                        HStack {
                            Text("Search Content:").bold()
                            Text("\(bookmark.searchContent.displayName)")
                        }
                        HStack {
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

