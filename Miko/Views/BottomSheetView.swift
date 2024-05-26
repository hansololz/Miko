import SwiftUI
import WebKit

struct BottomSheetView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    
    @State private var searchEngineOption: SearchEngineOption = loadSearchEnginePreference() {
        didSet {
            saveSearchEnginePreference(option: searchEngineOption)
        }
    }
    @State private var searchContentOption: SearchContentOption = loadSearchContentPreference() {
        didSet {
            saveSearchContentPreference(option: searchContentOption)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showMenu {
                    MenuView(
                        selectSheetAnchor: $selectSheetAnchor, 
                        showMenu: $showMenu,
                        searchText: $searchText,
                        sheetOffset: $sheetOffset,
                        searchEngineOption: $searchEngineOption,
                        searchContentOption: $searchContentOption
                    )
                } else if searchText.isEmpty {
                    WebView(urlString: getSearchUrl(engine: searchEngineOption, content: searchContentOption, searchText: searchText))
                        .opacity(0)
                    Text("Point the camera at text you want to look up.")
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .padding(.all, 20)
                } else {
                    WebView(urlString: getSearchUrl(engine: searchEngineOption, content: searchContentOption, searchText: searchText))
                }
            }
            .onAppear {
                sheetOffset = geometry.size.height
            }
            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                sheetOffset = newValue
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    
    class Coordinator: NSObject {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
