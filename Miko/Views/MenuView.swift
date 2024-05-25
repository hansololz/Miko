import SwiftUI

struct MenuView: View {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    
    var body: some View {
        VStack {
            Text("Menu Text")
                .multilineTextAlignment(.center)
                .background(Color.white)
                .padding(.all, 20)
        }
    }
}
