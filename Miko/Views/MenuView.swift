import SwiftUI

struct MenuView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    @Binding var searchEngineOption: SearchEngineOption {
        didSet {
            saveSearchEnginePreference(option: searchEngineOption)
            
            let contentOptions = searchEngineDirectory[searchEngineOption] ?? [:]
            if contentOptions[searchContentOption] == nil {
                if contentOptions[.images] == nil {
                    searchContentOption = .all
                } else {
                    searchContentOption = .images
                }
            }
        }
    }
    @Binding var searchContentOption: SearchContentOption {
        didSet {
            saveSearchContentPreference(option: searchContentOption)
        }
    }
    @Binding var locationInSearchQuery: Bool {
        didSet {
            saveLocationInSearchQueryPreference(preference: locationInSearchQuery)
        }
    }
    
    @State private var useLocationForSearchQuery: Bool = false
    
    var searchEngines: [SearchEngineOption] = [.google, .brave, .bing, .duckDuckGo, .baidu, .yandex]
    
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
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "doc")
                    }
                    NavigationLink(destination: ContactView()) {
                        Label("Contact", systemImage: "envelope")
                    }
                }
                
                Section(header: Text("Location")) {
                    Toggle(isOn: $useLocationForSearchQuery) {
                        Text("Use location in search query")
                    }
                }
                
                Section(header: Text("Search Engine")) {
                    ForEach(searchEngines, id: \.self) { option in
                        getSearchEngineOption(option: option)
                    }
                }
                
                Section(header: Text("Search Content: \(searchEngineOption)")) {
                    getSearchContentOption(engine: searchEngineOption, option: .all)
                    getSearchContentOption(engine: searchEngineOption, option: .images)
                    getSearchContentOption(engine: searchEngineOption, option: .videos)
                    getSearchContentOption(engine: searchEngineOption, option: .news)
                    getSearchContentOption(engine: searchEngineOption, option: .shopping)
                }
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
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func getSearchContentOption(engine: SearchEngineOption, option: SearchContentOption) -> some View {
        let contentOptions = searchEngineDirectory[engine] ?? [:]
        
        if contentOptions[option] != nil {
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
            .cornerRadius(10)
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            Section(header: Text("App Data")) {
                Text("The app itself, excluding the search engines, does not store any data externally. App settings data are only stored on device.")
            }
            
            Section(header: Text("Third Party Search Engines")) {
                Text("Third-party search engines used by this app may store data in browser cookies or externally. This data is controlled solely by the search engines, and you should follow their terms of use and privacy policy.\n\nThe app displays third party search engines as webpages in a browser view.")
            }
            
            Section(header: Text("Changes to This Privacy Policy")) {
                Text("We may update our privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page.")
            }
            
            Section(header: Text("Acceptance of Terms")) {
                Text("By using our app, you signify your acceptance of this privacy policy. If you do not agree to this policy, please do not use our app. Your continued use of the app following the posting of changes to this policy will be deemed your acceptance of those changes.")
            }
            
            Section(header: Text("Contact Us")) {
                Text("If you have any questions about this privacy policy, please contact us: -By email: nekocam@deezus.com")
                    .textSelection(.enabled)
            }
        }
        .navigationBarTitle("Privacy Policy")
    }
}

struct ContactView: View {
    var body: some View {
        List {
            Section() {
                Text("If you have any feedback, feature requests, or want to report an issue, please contact us: -By email: nekocam@deezus.com\n\nPlease do not include any personal information. If you are reporting an issue, please help us by including the steps to reproduce the issue.")
                    .textSelection(.enabled)
            }
        }
        .navigationBarTitle("Contact")
    }
}
