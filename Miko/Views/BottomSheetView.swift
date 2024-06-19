import SwiftUI
import WebKit
import SwiftData

struct BottomSheetView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showSettings: Bool
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    @Binding var settingsProfile: SearchConfig
    
    var modelContext: ModelContext
    @Query(sort: \SearchConfig.modifiedTime, order: .reverse) private var searchConfigs: [SearchConfig]
    @StateObject private var locationManager = LocationManager()
    @State private var settingsProfileId: PersistentIdentifier? = loadSettingsProfileId() {
        didSet {
            if let id = settingsProfileId {
                saveSettingsProfileId(id: id)
            }
        }
    }
    @State private var resetMenu: Bool = false
    @State private var resetSettings: Bool = false
    @State private var isInternetAvailable: Bool = true
    let monitor = NWPathMonitor()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !isInternetAvailable {
                    HStack {
                        Spacer()
                        Text("Internet not available. Please check your connection.")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, UIScreen.main.bounds.width * 0.15)
                        Spacer()
                    }
                } else if showMenu {
                    MenuView(
                        locationName: settingsProfile.useLocationInSearchQuery ? locationManager.locationName : "",
                        selectSheetAnchor: $selectSheetAnchor,
                        searchText: $searchText,
                        settingsProfile: $settingsProfile
                    )
                    .id(resetMenu)
                } else if showSettings {
                    SettingsView(
                        showSettings: $showSettings,
                        selectSheetAnchor: $selectSheetAnchor,
                        searchEngine: settingsProfile.searchEngine,
                        searchContent: settingsProfile.searchContent,
                        useLocationInSearchQuery: settingsProfile.useLocationInSearchQuery,
                        settingsProfileName: settingsProfile.name,
                        settingsProfile: $settingsProfile,
                        settingsProfileId: $settingsProfileId,
                        modelContext: modelContext
                    )
                    .id(resetSettings)
                } else if searchText.isEmpty {
                    if let url = getSearchUrl(
                        engine: settingsProfile.searchEngine,
                        content: settingsProfile.searchContent,
                        searchText: searchText,
                        locationName: "",
                        settingsProfile: settingsProfile
                    ) {
                        WebView(url: url)
                            .opacity(0)
                    }
                    Text("Point the camera at text you want to look up.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.15)
                } else {
                    VStack {
                        if let url = getSearchUrl(
                            engine: settingsProfile.searchEngine,
                            content: settingsProfile.searchContent,
                            searchText: searchText,
                            locationName: settingsProfile.useLocationInSearchQuery ? locationManager.locationName : "",
                            settingsProfile: settingsProfile
                        ) {
                            NavigationView{
                                VStack {
                                    WebView(url: url)
                                }
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                            self.showMenu = true
                                            self.selectSheetAnchor = fullSheetAnchor
                                        }) {
                                            Image(systemName: "ellipsis.circle")
                                        }
                                    }
                                    ToolbarItem(placement: .navigation) {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(searchConfigs) { searchConfig in
                                                    if searchConfig.id == settingsProfileId {
                                                        Button(action: {
                                                            
                                                        }) {
                                                            Text(searchConfig.name)
                                                        }
                                                        .buttonStyle(.borderedProminent)
                                                    } else {
                                                        Button(action: {
                                                            settingsProfileId = searchConfig.id
                                                            settingsProfile = searchConfig
                                                        }) {
                                                            Text(searchConfig.name)
                                                        }
                                                        .buttonStyle(.bordered)
                                                    }
                                                }
                                                
                                                Button(action: {
                                                    let searchConfig = createNewSearchConfig()
                                                    modelContext.insert(searchConfig)
                                                    try! modelContext.save()
                                                    
                                                    settingsProfileId = searchConfig.id
                                                    settingsProfile = searchConfig
                                                    
                                                    self.showSettings = true
                                                    self.selectSheetAnchor = fullSheetAnchor
                                                }) {
                                                    HStack {
                                                        Image(systemName: "plus")
                                                        Text("Add New Config")
                                                    }
                                                }
                                                .buttonStyle(.bordered)
                                                
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                            self.showSettings = true
                                            self.selectSheetAnchor = fullSheetAnchor
                                        }) {
                                            Image(systemName: "switch.2")
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            .onAppear {
                monitor.pathUpdateHandler = { path in
                    DispatchQueue.main.async {
                        self.isInternetAvailable = path.status == .satisfied
                    }
                }
                let queue = DispatchQueue(label: "NetworkMonitor")
                monitor.start(queue: queue)
                
                toggleLocationUpdate()
                if !locationManager.isAuthorized() {
                    settingsProfile.useLocationInSearchQuery = false
                }
            }
            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                sheetOffset = newValue
            }
            .onChange(of: selectSheetAnchor) { oldValue, newValue in
                toggleLocationUpdate()
            }
            .onChange(of: showMenu) { oldValue, newValue in
                if !newValue {
                    resetMenu.toggle()
                }
            }
            .onChange(of: showSettings) { oldValue, newValue in
                if !newValue {
                    resetSettings.toggle()
                }
            }
        }
    }
    
    private func toggleLocationUpdate() {
        if selectSheetAnchor == restSheetAnchor && locationManager.isAuthorized() && settingsProfile.useLocationInSearchQuery {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("window.scrollTo(0, 0);", completionHandler: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
