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
    @State private var searchText = ""
    
    var body: some View {
        CameraView(searchText: $searchText)
            .edgesIgnoringSafeArea(.all)
        BottomSheetView(searchText: $searchText)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

