import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = true
    @State private var searchText = ""
    @State private var selectSheetAnchor = restSheetAnchor
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var showMenu = false
    
    var body: some View {
        VStack {
            CameraView(selectSheetAnchor: $selectSheetAnchor, showMenu: $showMenu, searchText: $searchText, sheetOffset: $sheetOffset)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(selectSheetAnchor: $selectSheetAnchor, showMenu: $showMenu, searchText: $searchText, sheetOffset: $sheetOffset)
                .presentationDetents([restSheetAnchor, fullSheetAnchor], selection: $selectSheetAnchor)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(
                    .enabled(upThrough: restSheetAnchor)
                )
                .interactiveDismissDisabled()
        }
//        .onChange(of: selectSheetAnchor) { oldDetent, newDetent in
//            if newDetent == fullSheetAnchor {
//                showMenu = false
//            }
//        }
    }
}
