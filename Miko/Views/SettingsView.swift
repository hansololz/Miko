import SwiftUI
import SwiftData

var shouldShowAlertPrompt = false

struct SettingsView: View {
    @Binding var selectSheetAnchor: PresentationDetent
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
    @State var useLocationInSearchQuery: Bool {
        didSet {
            settingsProfile.useLocationInSearchQuery = useLocationInSearchQuery
        }
    }
    @State var isFirstEverLocationPermissionRequest: Bool = loadIsFirstEverLocationPermissionRequest() {
        didSet {
            saveIsFirstEverLocationPermissionRequest()
        }
    }
    @State var showingAlert = false
    @StateObject var locationManager = LocationManager()
    @Binding var translatePreference: TranslatePreference
    @Binding var settingsProfile: SettingsProfile
    var modelContext: ModelContext
    
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
                Section(header: Text("Languages")) {
                    NavigationLink(destination: SupportedLangaugesView(
                        settingsProfile: $settingsProfile,
                        selectedSearchLanguages: settingsProfile.supportLanguages
                    )) {
                        Label("Supported Languages", systemImage: "character.bubble")
                    }
                }
                
                Section(header: Text("Location")) {
                    Toggle(isOn: $useLocationInSearchQuery) {
                        Text("Use location in search query")
                    }
                    .onChange(of: useLocationInSearchQuery) { old, new in
                        if isFirstEverLocationPermissionRequest {
                            if !locationManager.isAuthorized() {
                                locationManager.requestAuthorization {
                                    shouldShowAlertPrompt = true
                                    useLocationInSearchQuery = locationManager.isAuthorized()
                                }
                            }
                            
                            isFirstEverLocationPermissionRequest = false
                        } else if shouldShowAlertPrompt {
                            shouldShowAlertPrompt = false
                        } else if !locationManager.isAuthorized() {
                            useLocationInSearchQuery = false
                            showingAlert = true
                        } else {
                            useLocationInSearchQuery = new
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Location Permission Needed"),
                            message: Text("This features requires \"While Using the App\" location access and percise location accuray. Please enable location services in your device settings."),
                            primaryButton: .default(Text("Go to Settings")) {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("Search Engine")) {
                    ForEach(searchEngines, id: \.self) { option in
                        getSearchEngineOption(option: option)
                    }
                }
                
                Section(header: Text("Search Content")) {
                    getSearchContentOption(engine: searchEngineOption, option: .all)
                    getSearchContentOption(engine: searchEngineOption, option: .images)
                    getSearchContentOption(engine: searchEngineOption, option: .videos)
                    getSearchContentOption(engine: searchEngineOption, option: .news)
                    getSearchContentOption(engine: searchEngineOption, option: .shopping)
                    getSearchContentOption(engine: searchEngineOption, option: .translate)
                }
                
                if searchContentOption == .translate {
                    Section(header: Text("Translate")) {
                        NavigationLink(destination: TranslateSettingsView(translatePreference: $translatePreference)) {
                            Label("Choose Language", systemImage: "character.bubble")
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("App Version: \(appVersion)")
                                .foregroundColor(.gray)
                        }
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.doc")
                    }
                    NavigationLink(destination: ContactView()) {
                        Label("Contact", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle("Settings")
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
                Text("The app itself, excluding the search engines, does not store any data externally. App settings data is only stored on the device.")
            }
            
            Section(header: Text("Camera Access")) {
                Text("Camera access is needed to find text to look up in the search engines. All image data is processed on the device, and data is never sent externally.")
            }
            
            Section(header: Text("Location Access")) {
                Text("Location access is needed when the \"use location in search query\" feature is enabled. The current location will be added to the search query for better results. Data is never sent externally.")
            }
            
            Section(header: Text("Third Party Search Engines")) {
                Text("Third-party search engines used by this app may store data in browser cookies or externally. This data is controlled solely by the search engines, and you should follow their terms of use and privacy policies.\n\nThe app displays third-party search engines as webpages in a browser view.")
            }
            
            Section(header: Text("Changes to This Privacy Policy")) {
                Text("We may update our privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page.")
            }
            
            Section(header: Text("Acceptance of Terms")) {
                Text("By using our app, you signify your acceptance of this privacy policy. If you do not agree with this policy, please do not use the app. Your continued use of the app following the posting of changes to this policy will be deemed your acceptance of those changes.")
            }
            
            Section(header: Text("Contact Me")) {
                Text("If you have any questions about this privacy policy, please contact me by email: browse@hansololz.com.")
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
                Text("If you have any feedback, feature requests, or want to report an issue, please contact me by email at browse@hansololz.com.\n\nPlease do not include any personal information. If you are reporting an issue, please help by including the steps to reproduce the issue.")
                    .textSelection(.enabled)
            }
        }
        .navigationBarTitle("Contact")
    }
}

// Always push English back to the end of the array. The Camera processes the langauges in order.
// If English is first in the array, characters from other languages won't be picked up.
struct SupportedLangaugesView: View {
    @Binding var settingsProfile: SettingsProfile
    @State var selectedSearchLanguages: [SearchLanguage] {
        didSet {
            settingsProfile.supportLanguages = selectedSearchLanguages
        }
    }
    
    var body: some View {
        List {
            ForEach(SearchLanguage.allCases, id: \.self) { language in
                LanguageRow(language: language, isSelected: selectedSearchLanguages.contains(language)) { isSelected in
                    let containsEnglish = selectedSearchLanguages.contains(.englishUS)
                    var languages = Array(selectedSearchLanguages)
                    
                    if isSelected {
                        if !languages.contains(language) {
                            languages.append(language)
                        }
                    } else {
                        if let index = languages.firstIndex(of: language) {
                            languages.remove(at: index)
                        }
                    }
                    
                    if containsEnglish && language != .englishUS {
                        if let index = languages.firstIndex(of: .englishUS) {
                            languages.remove(at: index)
                        }
                        
                        languages.append(.englishUS)
                    }
                    
                    if languages.isEmpty {
                        selectedSearchLanguages = [.englishUS]
                    } else {
                        selectedSearchLanguages = languages
                    }
                }
            }
        }
        .navigationTitle("Languages")
    }
}

struct LanguageRow: View {
    let language: SearchLanguage
    let isSelected: Bool
    let toggleSelection: (Bool) -> Void
    
    var body: some View {
        Toggle(isOn: Binding<Bool>(
            get: { isSelected },
            set: { newValue in toggleSelection(newValue) }
        )) {
            Text(language.displayName)
        }
    }
}

struct TranslateSettingsView: View {
    @Binding var translatePreference: TranslatePreference
    
    var body: some View {
        List {
            Section(header: Text("From")) {
                NavigationLink(destination: TranslateLanguageSelectionView(
                    isFrom: true,
                    translatePreference: $translatePreference
                )) {
                    Label(translatePreference.from.displayName, systemImage: "character.bubble")
                }
            }
            
            Section(header: Text("To")) {
                NavigationLink(destination: TranslateLanguageSelectionView(
                    isFrom: false,
                    translatePreference: $translatePreference
                )) {
                    Label(translatePreference.to.displayName, systemImage: "character.bubble")
                }
            }
        }
        .navigationBarTitle("Translate")
        .toolbar {
            Button(action: {
                translatePreference = TranslatePreference(
                    from: translatePreference.to,
                    to: translatePreference.from
                )
            }) {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
}

struct TranslateLanguageSelectionView: View {
    let isFrom: Bool
    @Binding var translatePreference: TranslatePreference {
        didSet {
            saveTranslateLanguagePreference(preference: translatePreference)
        }
    }
    
    var body: some View {
        List(TranslateLanguage.allCases, id: \.self) { language in
            Button(action: {
                if (isFrom) {
                    translatePreference = TranslatePreference(
                        from: language,
                        to: translatePreference.to
                    )
                } else {
                    translatePreference = TranslatePreference(
                        from: translatePreference.from,
                        to: language
                    )
                }
            }) {
                HStack {
                    Text(language.displayName)
                    Spacer()
                    if (isFrom && language == translatePreference.from) || (!isFrom && language == translatePreference.to) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationBarTitle("Languages")
    }
}
