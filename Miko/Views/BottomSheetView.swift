//
//  BottomSheet.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import Foundation
import UIKit
import SwiftUI

struct BottomSheetView: View {
    @State var showButtomSheet = false
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            Button("Shows sheet: \"\(searchText)\", click on tags") {
                showButtomSheet.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showButtomSheet) {
            Text("Tommy, process change should show here.")
            Text("Current text: \"\(searchText)\"")
        }
    }
}

#Preview {
    struct BottomwSheetPreview: View {
        @State private var searchText = "Preview Text"
        
        var body: some View {
            BottomSheetView(searchText: $searchText)
        }
    }

    return BottomwSheetPreview()
}
