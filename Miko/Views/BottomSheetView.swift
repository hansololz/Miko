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

struct SheetManager {
    static func preventDismissal() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            if let sheetPresentationController = rootViewController.presentedViewController?.presentationController as? UISheetPresentationController {
                sheetPresentationController.delegate = SheetDelegate.shared
            }
        }
    }
}

class SheetDelegate: NSObject, UISheetPresentationControllerDelegate {
    static let shared = SheetDelegate()
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
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
