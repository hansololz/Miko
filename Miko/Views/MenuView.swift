import SwiftUI

struct MenuView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    @Binding var searchEngineOption: SearchEngineOption
    @Binding var searchContentOption: SearchContentOption
//    @State private var isToggleOn: Bool = false
    
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
                    getSearchEngineOption(option: .google)
                    getSearchEngineOption(option: .bing)
                    getSearchEngineOption(option: .duckDuckGo)
                }
                
                Section(header: Text("Search Content")) {
                    getSearchContentOption(option: .all)
                    getSearchContentOption(option: .images)
                    getSearchContentOption(option: .videos)
                    getSearchContentOption(option: .news)
                    getSearchContentOption(option: .shopping)
                }
                
//                Section(header: Text("Toggle Section")) {
//                    Toggle("Enable Feature", isOn: $isToggleOn)
//                }
            }
            .navigationTitle("Neko Cam")
            .navigationBarItems(leading: Button("Done") {
                selectSheetAnchor = restSheetAnchor
            })
        }
    }
    
    private func getSearchEngineOption(option: SearchEngineOption) -> some View {
        Button(action: {
            searchEngineOption = option
        }) {
            HStack {
                Text(option.displayName)
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
    
    private func getSearchContentOption(option: SearchContentOption) -> some View {
        Button(action: {
            searchContentOption = option
        }) {
            HStack {
                Text(option.displayName)
                Spacer()
                if searchContentOption == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
    }
}
