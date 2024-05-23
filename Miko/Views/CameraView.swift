//
//  CameraView.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import AVFoundation
import SwiftUI
import Vision
import CoreMotion

struct CameraView: UIViewControllerRepresentable {
    @Binding var isSheetExpended: Bool
    @Binding var searchText: String
    
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func updateSearchText(_ text: String) {
            DispatchQueue.main.async {
                if !text.isEmpty && self.parent.searchText != text && !self.parent.isSheetExpended {
                    self.parent.searchText = text
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.coordinator = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let cameraViewController = uiViewController as? CameraViewController {
            if isSheetExpended {
                cameraViewController.pauseCamera()
            } else {
                cameraViewController.resumeCamera()
            }
        }
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var timer: Timer?
    var lastSampleBuffer: CMSampleBuffer?
    weak var coordinator: CameraView.Coordinator?
    var viewfinderIconView: UIImageView!
    var motionManager: CMMotionManager!
    var isDeviceMoving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            print("Error Unable to initialize back camera: \(error.localizedDescription)")
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        addViewfinderIconOverlay()
        setupMotionManager()
    }
    
    func addViewfinderIconOverlay() {
        let viewfinderIcon = UIImage(systemName: "dot.viewfinder") // Make sure to have the viewfinder.rectangular icon in your assets
        viewfinderIconView = UIImageView(image: viewfinderIcon)
        viewfinderIconView.translatesAutoresizingMaskIntoConstraints = false
        viewfinderIconView.contentMode = .scaleAspectFit
        viewfinderIconView.tintColor = .white // Set the color if needed
        view.addSubview(viewfinderIconView)
        
        let iconSize: CGFloat = 30
        
        NSLayoutConstraint.activate([
            viewfinderIconView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.5),
            viewfinderIconView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * viewFinderCenterY),
            viewfinderIconView.widthAnchor.constraint(equalToConstant: iconSize),
            viewfinderIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        lastSampleBuffer = sampleBuffer
        processSampleBuffer(sampleBuffer)
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: requestOptions)
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.handleDetectedText(request: request)
        }
        
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func handleDetectedText(request: VNRequest) {
        if isDeviceMoving { return }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        DispatchQueue.main.async {
            self.view.subviews.forEach { subview in
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            var smallestDistance: CGFloat = 10000
            var topText: String = ""
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                if topCandidate.string.count < 3 { continue }
                
                let xOffset: CGFloat = self.view.bounds.size.width
                let yOffset: CGFloat = self.view.bounds.size.height
                let transform = CGAffineTransform.identity
                    .scaledBy(x: xOffset, y: -yOffset)
                    .translatedBy(x: 0, y: -1)
                
                let rect = observation.boundingBox.applying(transform)
                let targetX = self.view.bounds.width * 0.5
                let targetY = self.view.bounds.height * viewFinderCenterY
                
                if !(rect.minX < targetX && targetX < rect.maxX && rect.minY < targetY && targetY < rect.maxY) {
                    continue
                }
                
                let centerX = rect.midX
                let centerY = rect.midY
                
                let distance = abs(centerX - targetX) * abs(centerY - targetY)
                
                if distance < smallestDistance {
                    smallestDistance = distance
                    topText = topCandidate.string
                }
            }
            
            self.coordinator?.updateSearchText(topText)
        }
    }
    
    func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.1
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motion, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            if let motion = motion {
                self.isDeviceMoving = abs(motion.userAcceleration.x) > 0.03 ||
                abs(motion.userAcceleration.y) > 0.03 ||
                abs(motion.userAcceleration.z) > 0.03
            }
        }
    }
    
    func pauseCamera() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
    
    func resumeCamera() {
        DispatchQueue.global(qos: .background).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
}

#Preview {
    struct CameraView_Preview: View {
        @State private var isSheetExpended = false
        @State private var searchText = "Preview Text"
        
        var body: some View {
            CameraView(isSheetExpended: $isSheetExpended, searchText: $searchText)
        }
    }
    
    return CameraView_Preview()
}
