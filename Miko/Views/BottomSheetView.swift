//
//  BottomSheet.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct BottomSheetView: View {
    @Binding var isSheetExpended: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            if searchText.isEmpty {
                Text("Point the camera at text you want to look up and see search results.")
                    .multilineTextAlignment(.center)
                    .padding(.all, 20)
            } else {
                WebView(urlString: "https://www.google.com/search?tbm=isch&q=\(searchText)")
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

#Preview {
    struct BottomwSheetPreview: View {
        @State private var isSheetExpended = true
        @State private var searchText = "Preview Text"
        
        var body: some View {
            BottomSheetView(isSheetExpended: $isSheetExpended, searchText: $searchText)
        }
    }
    
    return BottomwSheetPreview()
}
