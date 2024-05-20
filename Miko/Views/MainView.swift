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

struct MainView: View {
    @State private var image: UIImage? = nil
    @State private var isShowingCamera = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No Image")
                    .foregroundColor(.gray)
                    .font(.largeTitle)
            }
            
            Button(action: {
                isShowingCamera = true
            }) {
                Text("Take Photo")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraView(image: $image)
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


//struct MainContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//    var body: some View {
//        FullCameraView()
//            .edgesIgnoringSafeArea(.all)
//    }
//}
//
//struct FullCameraView: UIViewControllerRepresentable {
//    class Coordinator: NSObject {
//        var parent: FullCameraView
//        
//        init(parent: FullCameraView) {
//            self.parent = parent
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let cameraViewController = CameraViewController()
//        return cameraViewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
//
//class CameraViewController: UIViewController {
//    
//    var captureSession: AVCaptureSession?
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupCamera()
//    }
//    
//    func setupCamera() {
//        // Initialize the capture session
//        captureSession = AVCaptureSession()
//        captureSession?.sessionPreset = .high
//        
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            print("Failed to get the camera device")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: captureDevice)
//            if let captureSession = captureSession {
//                captureSession.addInput(input)
//                
//                // Set up preview layer
//                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                videoPreviewLayer?.videoGravity = .resizeAspectFill
//                videoPreviewLayer?.frame = view.layer.bounds
//                if let videoPreviewLayer = videoPreviewLayer {
//                    view.layer.addSublayer(videoPreviewLayer)
//                }
//                
//                // Start the capture session
//                captureSession.startRunning()
//            }
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
//    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//}

#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
}

