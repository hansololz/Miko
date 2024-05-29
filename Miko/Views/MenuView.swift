import SwiftUI

struct MenuView: View {
    let locationName: String
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var searchText: String
    @State private var showCopiedMessage = false
    @State private var copiedMessageOpacity = 0.0

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Copy")) {
                        Button(action: {
                            copyToClipboard(text: "Sample text to copy")
                        }) {
                            Label("Copy Text", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            copyToClipboard(text: "Text without location")
                        }) {
                            Label("Copy Text Without Location", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            copyToClipboard(text: "https://example.com")
                        }) {
                            Label("Copy URL", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            copyToClipboard(text: "https://example.com without location")
                        }) {
                            Label("Copy URL Without Location", systemImage: "doc.on.doc")
                        }
                    }
                    
                    Section(header: Text("Share")) {
                        Label("Share Text", systemImage: "square.and.arrow.up")
                        Label("Share Text Without Location", systemImage: "square.and.arrow.up")
                        Label("Share URL", systemImage: "square.and.arrow.up")
                        Label("Share URL Without Location", systemImage: "square.and.arrow.up")
                    }
                }
                .navigationTitle(searchText)
                .navigationBarItems(leading: Button("Done") {
                    selectSheetAnchor = restSheetAnchor
                })
                
//                if showCopiedMessage {
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
//                }
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
}
