import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = true
    @State private var isSheetExpended = false
    @State private var searchText = ""
    @State private var selectedDetent = restSheetAnchor
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var showMenu = false
    
    var body: some View {
        VStack {
            CameraView(isSheetExpended: $isSheetExpended, showMenu: $showMenu, searchText: $searchText, sheetOffset: $sheetOffset)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isSheetExpended: $isSheetExpended, showMenu: $showMenu, searchText: $searchText, sheetOffset: $sheetOffset)
                .presentationDetents([restSheetAnchor, fillSheetAnchor], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(
                    .enabled(upThrough: restSheetAnchor)
                )
                .interactiveDismissDisabled()
        }
        .onChange(of: selectedDetent) { oldDetent, newDetent in
            isSheetExpended = (newDetent != restSheetAnchor)
        }
    }
}
