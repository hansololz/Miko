import SwiftUI

struct MenuView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    
    @State private var searchEngineOption: String? = "Google"
    
    private var appVersion: String {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return version
            } else {
                return "1.0"
            }
        }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("App Version: \(appVersion)")
                                .foregroundColor(.gray)
                        }
                    }
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "doc")
                    }
                    NavigationLink(destination: Text("Contact")) {
                        Label("Contact", systemImage: "envelope")
                    }
                }
                
                Section(header: Text("Search Engine")) {
                    getSearchEngineOption(option: "Google")
                    getSearchEngineOption(option: "Bing")
                    getSearchEngineOption(option: "DuckDuckGo")
                }
            }
            .navigationTitle("Neko Cam")
            .navigationBarItems(leading: Button("Done") {
                selectSheetAnchor = restSheetAnchor
            })
        }
    }
    
    private func getSearchEngineOption(option: String) -> some View {
        Button(action: {
            searchEngineOption = option
        }) {
            HStack {
                Text(option)
                Spacer()
                if searchEngineOption == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
    }
}
