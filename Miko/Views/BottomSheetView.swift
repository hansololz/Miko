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
    @StateObject private var locationManager = LocationManager()
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
                        selectSheetAnchor: $selectSheetAnchor,
                        searchEngine: settingsProfile.searchEngine,
                        searchContent: settingsProfile.searchContent,
                        useLocationInSearchQuery: settingsProfile.useLocationInSearchQuery,
                        settingsProfile: $settingsProfile,
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
                    if let url = getSearchUrl(
                        engine: settingsProfile.searchEngine,
                        content: settingsProfile.searchContent,
                        searchText: searchText,
                        locationName: settingsProfile.useLocationInSearchQuery ? locationManager.locationName : "",
                        settingsProfile: settingsProfile
                    ) {
                        WebView(url: url)
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
