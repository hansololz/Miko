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
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            CameraView(searchText: $searchText)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isSheetPresented: $isSheetPresented, searchText: $searchText)
                .presentationDetents([.fraction(0.30), .large])
                .presentationDragIndicator(.visible)
                .onAppear {
                    preventDismissal()
                }
        }
    }
    
    private func preventDismissal() {
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
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

