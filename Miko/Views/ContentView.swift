import SwiftData
import SwiftUI
import AVFoundation

func saveIsFirstEverCameraPermissionRequest() {
    UserDefaults.standard.set(false, forKey: "isFirstEverCameraPermissionRequest")
}

func loadIsFirstEverCameraPermissionRequest() -> Bool {
    let userDefaults = UserDefaults.standard
    if userDefaults.object(forKey: "isFirstEverCameraPermissionRequest") == nil {
        return true
    } else {
        return userDefaults.bool(forKey: "isFirstEverCameraPermissionRequest")
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]
    
    @State private var isCameraReady = false
    @State private var searchText = ""
    @State private var selectSheetAnchor = restSheetAnchor
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var showSettings = false
    @State private var showMenu = false
    @State private var isFirstEverCameraPermissionRequest = loadIsFirstEverCameraPermissionRequest()
    @State private var selectedSearchLanguages: [SearchLanguage] = loadCameraSearchLanguages()
    @State private var cameraOverlayAlpha = 0.0
    
    var body: some View {
        VStack {
            if isCameraReady {
                ZStack {
                    CameraView(
                        selectSheetAnchor: $selectSheetAnchor,
                        showSettings: $showSettings,
                        showMenu: $showMenu,
                        searchText: $searchText,
                        isFirstEverCameraPermissionRequest: $isFirstEverCameraPermissionRequest,
                        selectedSearchLanguages: $selectedSearchLanguages
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
                                
//                                print("ALPHA: \(sheetOffset) | \(alpha)")
                            }
                        }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                if isFirstEverCameraPermissionRequest {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Camera access is required for finding text to look up. Please enable access for this app.")
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
        }
        .sheet(isPresented: $isCameraReady) {
            BottomSheetView(
                selectSheetAnchor: $selectSheetAnchor,
                showSettings: $showSettings,
                showMenu: $showMenu,
                searchText: $searchText,
                sheetOffset: $sheetOffset,
                selectedSearchLanguages: $selectedSearchLanguages
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
}
