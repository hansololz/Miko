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
    @Binding var isSheetExpended: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            Text("Tommy, process change should show here.")
            Text("Is sheet expended: \"\(isSheetExpended)\"")
            Text("Current text: \"\(searchText)\"")
        }
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
