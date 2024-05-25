import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = true
    @State private var isSheetExpended = false
    @State private var searchText = ""
    @State private var selectedDetent: PresentationDetent = .fraction(bottomSheetAnchor)
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        VStack {
            CameraView(isSheetExpended: $isSheetExpended, searchText: $searchText, sheetOffset: $sheetOffset)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isSheetExpended: $isSheetExpended, searchText: $searchText, sheetOffset: $sheetOffset)
                .presentationDetents([.fraction(bottomSheetAnchor), .fraction(0.999)], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(
                    .enabled(upThrough: .fraction(bottomSheetAnchor))
                )
                .interactiveDismissDisabled()
        }
        .onChange(of: selectedDetent) { oldDetent, newDetent in
            isSheetExpended = (newDetent != .fraction(bottomSheetAnchor))
        }
    }
}
