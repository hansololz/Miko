import SwiftData
import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]
    @Query private var searchConfigs: [SearchConfiguration]
    @State private var isCameraReady = false
    @State private var searchText = ""
    @State private var selectSheetAnchor = restSheetAnchor
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var showSettings = false
    @State private var showMenu = false
    @State private var cameraOverlayAlpha = 0.0
    @State private var selectedSearchConfig = createNewSearchConfig()
    
    var body: some View {
        VStack {
            if isCameraReady {
                ZStack {
                    CameraView(
                        selectSheetAnchor: $selectSheetAnchor,
                        showSettings: $showSettings,
                        showMenu: $showMenu,
                        searchText: $searchText,
                        selectedSearchConfig: $selectedSearchConfig
                    )
                    Rectangle()
                        .fill(.black)
                        .opacity(cameraOverlayAlpha)
                        .onChange(of: sheetOffset) { newValue, oldValue in
                            if (sheetOffset != 0.0) {
                                let offsetFloat = (UIScreen.main.bounds.height - sheetOffset)/UIScreen.main.bounds.height
                                let truncatedOffset = max(min(offsetFloat, cameraFadeOutHeight), cameraFadeInHeight)
                                let alpha = (truncatedOffset - cameraFadeInHeight)/fadeInAndOutHeightDifference
                                cameraOverlayAlpha = alpha
                            }
                        }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                Text("Camera access is required for finding text to show search results for. Please enable access for this app.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.15)
                Button(action: {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                }) {
                    Text("Go to Settings")
                }
            }
        }
        .sheet(isPresented: $isCameraReady) {
            BottomSheetView(
                selectSheetAnchor: $selectSheetAnchor,
                showSettings: $showSettings,
                showMenu: $showMenu,
                searchText: $searchText,
                sheetOffset: $sheetOffset,
                selectedSearchConfig: $selectedSearchConfig,
                modelContext: modelContext
            )
            .presentationDetents([restSheetAnchor, fullSheetAnchor], selection: $selectSheetAnchor)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(
                .enabled(upThrough: restSheetAnchor)
            )
            .interactiveDismissDisabled()
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: selectSheetAnchor) { oldDetent, newDetent in
            if newDetent == restSheetAnchor {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    showMenu = false
                    showSettings = false
                }
            }
        }
        .onAppear {
            selectedSearchConfig = getSelectedSearchConfig(searchConfigs: searchConfigs)
            checkCameraPermission()
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraReady = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isCameraReady = granted
                }
            }
        default:
            isCameraReady = false
        }
    }
    
    private func getSelectedSearchConfig(searchConfigs: [SearchConfiguration]) -> SearchConfiguration {
        let selectedSearchConfigId = loadSelectedSearchConfigId()
        
        if let selectedSearchConfig = searchConfigs.first(where: {
            $0.id == selectedSearchConfigId
        }) {
            return selectedSearchConfig
        }
        
        if let newestSearchConfig = searchConfigs.max(by: { s1, s2 in
            s1.createdTime > s2.createdTime
        }) {
            saveSelectedSearchConfigId(id: newestSearchConfig.id)
            return newestSearchConfig
        }
        
        let defaultSearchConfigs = createDefaultSearchConfigs()
        
        defaultSearchConfigs.forEach { searchConfig in
            modelContext.insert(searchConfig)
        }
        try! modelContext.save()
        
        let firstSearchConfig = defaultSearchConfigs[0]
        
        saveSelectedSearchConfigId(id: firstSearchConfig.id)
        
        return firstSearchConfig
    }
}
