import Foundation
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
                    Section(header: Text("Search Query")) {
                        Text("Search Text: \(searchText)")
                        
//                        if !locationName.isEmpty {
                        
                            Text("Location: \(locationName)")
//                        }
                        
                        Text("Search Engine: \(searchEngineOption.displayName)")
                        Text("Search Content: \(searchContentOption.displayName)")
                    }
                    .onAppear {
                        print("HERE \(locationName)")
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
                                Label("Copy Text Without Location", systemImage: "doc.on.doc")
                            }
                        }
                        
                        Button(action: {
//                            let url = getSearchUrl(
//                                engine: searchEngineOption,
//                                content: searchContentOption,
//                                searchText: searchText,
//                                locationManager: locationManager
//                            )
//                            copyToClipboard(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                        }) {
                            Label("Copy URL", systemImage: "doc.on.doc")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
//                                let url = getSearchUrl(
//                                    engine: searchEngineOption,
//                                    content: searchContentOption,
//                                    searchText: searchText,
//                                    locationManager: locationManager
//                                )
//                                copyToClipboard(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                            }) {
                                Label("Copy URL Without Location", systemImage: "doc.on.doc")
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
                                Label("Share Text Without Location", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Button(action: {
//                            let url = getSearchUrl(
//                                engine: searchEngineOption,
//                                content: searchContentOption,
//                                searchText: searchText,
//                                locationManager: locationManager
//                            )
//                            shareText(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                        }) {
                            Label("Share URL", systemImage: "square.and.arrow.up")
                        }
                        
                        if !locationName.isEmpty {
                            Button(action: {
//                                let url = getSearchUrl(
//                                    engine: searchEngineOption,
//                                    content: searchContentOption,
//                                    searchText: searchText,
//                                    locationManager: locationManager
//                                )
//                                shareText(text: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)
                            }) {
                                Label("Share URL Without Location", systemImage: "square.and.arrow.up")
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
