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
    @State private var isSheetPresented = false
    @State private var searchText = ""
    @State private var selectSheetAnchor = restSheetAnchor
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var showMenu = false
    @State private var isFirstEverCameraPermissionRequest = loadIsFirstEverCameraPermissionRequest()
    @State private var selectedSearchLanguages: [SearchLanguage] = loadCameraSearchLanguages()
    
    var body: some View {
        VStack {
            if isSheetPresented {
                CameraView(
                    selectSheetAnchor: $selectSheetAnchor,
                    showMenu: $showMenu,
                    searchText: $searchText,
                    sheetOffset: $sheetOffset,
                    isFirstEverCameraPermissionRequest: $isFirstEverCameraPermissionRequest,
                    selectedSearchLanguages: $selectedSearchLanguages
                )
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
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(
                selectSheetAnchor: $selectSheetAnchor,
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
            isSheetPresented = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isSheetPresented = granted
                }
            }
        default:
            isSheetPresented = false
        }
    }
}
