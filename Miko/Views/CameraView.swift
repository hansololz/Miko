//
//  CameraView.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import AVFoundation
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CameraViewController()
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if let captureSession = captureSession {
                captureSession.addInput(input)
                
                // Set up preview layer
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                if let videoPreviewLayer = videoPreviewLayer {
                    view.layer.addSublayer(videoPreviewLayer)
                }
                
                // Start the capture session
                captureSession.startRunning()
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
