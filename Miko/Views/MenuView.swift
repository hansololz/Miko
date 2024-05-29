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
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
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
                                Label("Copy Text Without Location", systemImage: "doc.on.doc")
                            }
                        }
                        
                        Button(action: {
                            copyToClipboard(
                                text: getSearchUrl(
                                    engine: searchEngineOption,
                                    content: searchContentOption,
                                    searchText: searchText,
                                    locationName: ""
                                )
                            )
                        }) {
                            Label("Copy URL", systemImage: "doc.on.doc")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
                                copyToClipboard(
                                    text: getSearchUrl(
                                        engine: searchEngineOption,
                                        content: searchContentOption,
                                        searchText: searchText,
                                        locationName: locationName
                                    )
                                )
                            }) {
                                Label("Copy URL Without Location", systemImage: "doc.on.doc")
                            }
                        }
                    }
                    
                    Section(header: Text("Share")) {
                        Button(action: {
                            shareText(text: searchText)
                        }) {
                            Label("Share Text", systemImage: "doc.on.doc")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
                                shareText(text: "\(searchText), \(locationName)")
                            }) {
                                Label("Share Text Without Location", systemImage: "doc.on.doc")
                            }
                        }
                        
                        Button(action: {
                            shareText(
                                text: getSearchUrl(
                                    engine: searchEngineOption,
                                    content: searchContentOption,
                                    searchText: searchText,
                                    locationName: ""
                                )
                            )
                        }) {
                            Label("Share URL", systemImage: "doc.on.doc")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
                                shareText(
                                    text: getSearchUrl(
                                        engine: searchEngineOption,
                                        content: searchContentOption,
                                        searchText: searchText,
                                        locationName: locationName
                                    )
                                )
                            }) {
                                Label("Share URL Without Location", systemImage: "doc.on.doc")
                            }
                        }
                    }
                    
                }
                .navigationTitle("Options")
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

    }
}
