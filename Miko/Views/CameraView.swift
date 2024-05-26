import AVFoundation
import SwiftUI
import Vision
import CoreMotion
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var sheetOffset: CGFloat
    
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func updateSearchText(_ text: String) {
            DispatchQueue.main.async {
                if !text.isEmpty && self.parent.searchText != text && self.parent.selectSheetAnchor == restSheetAnchor {
                    self.parent.searchText = text
                }
            }
        }
        
        func showMenu() {
            DispatchQueue.main.async {
                self.parent.showMenu = true
                self.parent.selectSheetAnchor = fullSheetAnchor
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
            if selectSheetAnchor == restSheetAnchor {
                cameraViewController.resumeCamera()
            } else {
                cameraViewController.pauseCamera()
            }
            
            if (sheetOffset != 0.0) {
                let offsetFloat = (UIScreen.main.bounds.height - sheetOffset)/UIScreen.main.bounds.height
                let truncatedOffset = max(min(offsetFloat, cameraFadeOutHeight), cameraFadeInHeight)
                let alpha = (truncatedOffset - cameraFadeInHeight)/fadeInAndOutHeightDifference
                cameraViewController.updateOverlayAlpha(alpha)
            }
        }
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var overlayView: UIView!
    var timer: Timer?
    var lastSampleBuffer: CMSampleBuffer?
    weak var coordinator: CameraView.Coordinator?
    var viewfinderIconView: UIImageView!
    var menuIconView: UIImageView!
    var motionManager: CMMotionManager!
    var isDeviceMoving = false
    var lastTextProcessedTimestamp = DispatchTime.now().uptimeNanoseconds / 1_000_000
    var shouldSampleText = true
    var currentZoomFactor: CGFloat = 1.0
    
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
        
        // Add overlay view
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
        
        captureSession.startRunning()
        
        addViewfinderIconOverlay()
        addMenuIconOverlay()
        
        setupMotionManager()
        setupPinchGesture()
    }
    
    func addViewfinderIconOverlay() {
        let viewfinderIcon = UIImage(systemName: "dot.viewfinder")
        viewfinderIconView = UIImageView(image: viewfinderIcon)
        viewfinderIconView.translatesAutoresizingMaskIntoConstraints = false
        viewfinderIconView.contentMode = .scaleAspectFit
        viewfinderIconView.tintColor = .white
        view.addSubview(viewfinderIconView)
        
        let iconSize: CGFloat = 30
        
        NSLayoutConstraint.activate([
            viewfinderIconView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.5),
            viewfinderIconView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * viewFinderCenterY),
            viewfinderIconView.widthAnchor.constraint(equalToConstant: iconSize),
            viewfinderIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }
    
    func addMenuIconOverlay() {
        let menuIcon = UIImage(systemName: "ellipsis.circle")
        
        // Create a container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = true
        view.addSubview(containerView)
        
        // Create the icon view
        menuIconView = UIImageView(image: menuIcon)
        menuIconView.translatesAutoresizingMaskIntoConstraints = false
        menuIconView.contentMode = .scaleAspectFit
        menuIconView.tintColor = .white
        containerView.addSubview(menuIconView)
        
        let iconSize: CGFloat = 30
        let touchAreaSize: CGFloat = 90 // Increase this value to make the touch area larger
        
        // Constraints for the container view
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - (touchAreaSize / 2)),
            containerView.widthAnchor.constraint(equalToConstant: touchAreaSize),
            containerView.heightAnchor.constraint(equalToConstant: touchAreaSize)
        ])
        
        // Center the icon view inside the container view
        NSLayoutConstraint.activate([
            menuIconView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            menuIconView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - iconSize),
            menuIconView.widthAnchor.constraint(equalToConstant: iconSize),
            menuIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        // Add tap gesture recognizer to the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuIconTapped))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    // Action method for tap gesture
    @objc func menuIconTapped() {
        coordinator?.showMenu()
    }
    
    func setupPinchGesture() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if pinch.state == .changed {
            let maxZoomFactor = min(device.activeFormat.videoMaxZoomFactor, 10.0)
            let newZoomFactor = min(max(1.0, currentZoomFactor * pinch.scale), maxZoomFactor)
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoomFactor
                device.unlockForConfiguration()
                
                currentZoomFactor = newZoomFactor
                pinch.scale = 1.0
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        lastSampleBuffer = sampleBuffer
        processSampleBuffer(sampleBuffer)
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if !shouldSampleText { return }
        
        let currentTime: UInt64 = DispatchTime.now().uptimeNanoseconds / 1_000_000
        
        if (currentTime - cameraSampleDelay) > lastTextProcessedTimestamp {
            lastTextProcessedTimestamp = currentTime
        } else {
            return
        }
        
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
        
        // Specify the recognition languages
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "ja", "ko", "en"]
        
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
                if topCandidate.string.count < minimumSearchTextLength { continue }
                
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
                self.isDeviceMoving = abs(motion.userAcceleration.x) > maximumUserAcceleration ||
                abs(motion.userAcceleration.y) > maximumUserAcceleration ||
                abs(motion.userAcceleration.z) > maximumUserAcceleration
            }
        }
    }
    
    func pauseCamera() {
        shouldSampleText = false
    }
    
    func resumeCamera() {
        shouldSampleText = true
    }
    
    func updateOverlayAlpha(_ alpha: CGFloat) {
        overlayView.alpha = alpha
    }
}
