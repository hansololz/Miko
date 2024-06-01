import SwiftUI
import WebKit

struct BottomSheetView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showSettings: Bool
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    @Binding var selectedSearchLanguages: [SearchLanguage]
    @StateObject private var locationManager = LocationManager()
    @State private var searchEngineOption: SearchEngineOption = loadSearchEnginePreference()
    @State private var searchContentOption: SearchContentOption = loadSearchContentPreference()
    @State private var locationInSearchQuery: Bool = loadLocationInSearchQueryPreference() {
        didSet {
            saveLocationInSearchQueryPreference(preference: locationInSearchQuery)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showMenu {
                    MenuView(
                        locationName: locationInSearchQuery ? locationManager.locationName : "",
                        selectSheetAnchor: $selectSheetAnchor,
                        searchText: $searchText,
                        searchEngineOption: $searchEngineOption,
                        searchContentOption: $searchContentOption
                    )
                } else if showSettings {
                    SettingsView(
                        selectSheetAnchor: $selectSheetAnchor,
                        searchEngineOption: $searchEngineOption,
                        searchContentOption: $searchContentOption,
                        locationInSearchQuery: $locationInSearchQuery,
                        selectedSearchLanguages: $selectedSearchLanguages
                    )
                } else if searchText.isEmpty {
                    if let url = getSearchUrl(
                        engine: searchEngineOption,
                        content: searchContentOption,
                        searchText: searchText,
                        locationName: ""
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
                        engine: searchEngineOption,
                        content: searchContentOption,
                        searchText: searchText,
                        locationName: locationInSearchQuery ? locationManager.locationName : ""
                    ) {
                        WebView(url: url)
                    }
                }
            }
            .onAppear {
                toggleLocationUpdate()
                if !locationManager.isAuthorized() {
                    locationInSearchQuery = false
                }
            }
            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                sheetOffset = newValue
            }
            .onChange(of: selectSheetAnchor) { oldValue, newValue in
                toggleLocationUpdate()
            }
        }
    }
    
    private func toggleLocationUpdate() {
        if selectSheetAnchor == restSheetAnchor && locationManager.isAuthorized() && locationInSearchQuery {
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
