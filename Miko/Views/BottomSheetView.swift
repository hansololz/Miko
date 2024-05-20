//
//  BottomSheet.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import Foundation
import UIKit
import SwiftUI

struct BottomSheetEntryView: View {
    @State var showButtomSheet = false
    
    var body: some View {
        VStack {
            Button("Shows sheet") {
                showButtomSheet.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showButtomSheet) {
            Text("This is s bottom sheet")
        }
    }
}
