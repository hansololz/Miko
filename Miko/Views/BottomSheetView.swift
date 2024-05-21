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
    @Binding var isSheetPresented: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            Text("Tommy, process change should show here.")
            Text("Current text: \"\(searchText)\"")
            .padding()
        }
    }
}

#Preview {
    struct BottomwSheetPreview: View {
        @State var isSheetPresented = true
        @State private var searchText = "Preview Text"
        
        var body: some View {
            BottomSheetView(isSheetPresented: $isSheetPresented, searchText: $searchText)
        }
    }

    return BottomwSheetPreview()
}
