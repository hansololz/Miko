//
//  MainView.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation
import SwiftData

struct ContentView: View {
    @State private var isSheetPresented = true
    @State private var isSheetExpended = false
    @State private var searchText = ""
    @State private var selectedDetent: PresentationDetent = .fraction(bottomSheetAnchor)
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    
//    @State private var sheetOpacity: Double {
//        let fullScreenHeight = UIScreen.main.bounds.height
//        let fraction = Double(sheetOffset / fullScreenHeight)
//        
//        print("HERE \(fullScreenHeight) | \(sheetOffset) | \(fraction) | \(min(1.0, max(0.0, 1.0 - fraction)))")
//        
//        return min(1.0, max(0.0, 1.0 - fraction))
//    }
    
    var body: some View {
        VStack {
            CameraView(isSheetExpended: $isSheetExpended, searchText: $searchText, sheetOffset: $sheetOffset)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isSheetExpended: $isSheetExpended, searchText: $searchText, sheetOffset: $sheetOffset)
                .presentationDetents([.fraction(bottomSheetAnchor), .fraction(0.999)], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        .onChange(of: selectedDetent) { oldDetent, newDetent in
            isSheetExpended = (newDetent != .fraction(bottomSheetAnchor))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
