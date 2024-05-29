import SwiftUI
import WebKit

struct BottomSheetView: View {
    @StateObject var locationManager = LocationManager()
    
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showSettings: Bool
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    @Binding var selectedSearchLanguages: [SearchLanguage]
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
                    SettingsView(
                        selectSheetAnchor: $selectSheetAnchor,
                        sheetOffset: $sheetOffset,
                        searchEngineOption: $searchEngineOption,
                        searchContentOption: $searchContentOption,
                        locationInSearchQuery: $locationInSearchQuery,
                        selectedSearchLanguages: $selectedSearchLanguages
                    )
                } else if searchText.isEmpty {
                    WebView(urlString: getSearchUrl(engine: searchEngineOption, content: searchContentOption, searchText: searchText, locationManager: locationManager))
                        .opacity(0)
                    Text("Point the camera at text you want to look up.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.15)
                } else {
                    WebView(urlString: getSearchUrl(engine: searchEngineOption, content: searchContentOption, searchText: searchText, locationManager: locationManager))
                        .onAppear {
                            if locationManager.isAuthorized() && locationInSearchQuery {
                                locationManager.startUpdatingLocation()
                            } else {
                                locationManager.stopUpdatingLocation()
                            }
                        }
                }
            }
            .onAppear {
                sheetOffset = geometry.size.height
                
                if locationManager.isAuthorized() && locationInSearchQuery {
                    locationManager.startUpdatingLocation()
                } else {
                    locationInSearchQuery = false
                }
            }
            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                sheetOffset = newValue
            }
        }
    }
}


struct WebView: UIViewRepresentable {
    let urlString: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Execute JavaScript to scroll to the top of the page
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
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
