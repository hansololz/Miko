import AVFoundation
import SwiftUI
import Vision
import CoreMotion
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectSheetAnchor: PresentationDetent
    @Binding var showSettings: Bool
    @Binding var showMenu: Bool
    @Binding var searchText: String
    @Binding var selectedSearchConfig: SearchConfiguration
    
    class Coordinator: NSObject {
        var lastTextUpdateTimestamp = DispatchTime.now().uptimeNanoseconds / 1_000_000
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func updateSearchText(_ text: String) {
            let currentTime: UInt64 = DispatchTime.now().uptimeNanoseconds / 1_000_000
            if text.isEmpty || self.parent.searchText == text || self.parent.selectSheetAnchor != restSheetAnchor || currentTime - cameraTextUpdateDelay < lastTextUpdateTimestamp { return }
            lastTextUpdateTimestamp = currentTime
            
            DispatchQueue.main.async {
                self.parent.searchText = text
            }
        }
        
        func showMenu() {
            DispatchQueue.main.async {
                self.parent.showMenu = true
                self.parent.selectSheetAnchor = fullSheetAnchor
            }
        }
        
        func showSettings() {
            DispatchQueue.main.async {
                self.parent.showSettings = true
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
        cameraViewController.selectedSearchLanguages = selectedSearchConfig.supportLanguages.map { $0.rawValue }
        print("LANGUAGE 1 \(cameraViewController.selectedSearchLanguages)")
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let cameraViewController = uiViewController as? CameraViewController {
            if selectSheetAnchor == restSheetAnchor {
                cameraViewController.isSheetAtRest = true
                cameraViewController.resumeCamera()
            } else {
                cameraViewController.isSheetAtRest = false
                cameraViewController.pauseCamera()
            }
            
            cameraViewController.selectedSearchLanguages = selectedSearchConfig.supportLanguages.map { $0.rawValue }
            print("LANGUAGE 2 \(cameraViewController.selectedSearchLanguages)")
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
    var settingsIconView: UIImageView!
    var menuIconView: UIImageView!
    var motionManager: CMMotionManager!
    var isDeviceMoving = false
    var lastSampleProcessTimestamp = DispatchTime.now().uptimeNanoseconds / 1_000_000
    var shouldSampleText = true
    var currentZoomFactor: CGFloat = 1.0
    var selectedSearchLanguages: [String] = ["en-US"]
    var isSheetAtRest = true
    
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
        
        addViewfinderIconOverlay()
        addDoubleTapGesture()
        
        setupMotionManager()
        setupPinchGesture()
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willEnterForeground() {
        if isSheetAtRest {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    @objc func didEnterBackground() {
        self.captureSession.stopRunning()
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
    
    func addDoubleTapGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        print("Double-tap detected")
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.videoZoomFactor == 1.0 {
            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: 2.0, withRate: 16.0)
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error)")
            }
        } else {
            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: 1.0, withRate: 16.0)
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error)")
            }
        }
    }
    
    @objc func settingsIconTapped() {
        coordinator?.showSettings()
    }
    
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
        
        if (currentTime - cameraSampleDelay) > lastSampleProcessTimestamp {
            lastSampleProcessTimestamp = currentTime
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
        
        request.recognitionLanguages = selectedSearchLanguages
        
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
        DispatchQueue.global(qos: .background).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
        print("CAMERA PAUSE")
        shouldSampleText = false
    }
    
    func resumeCamera() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        print("CAMERA START")
        shouldSampleText = true
    }
}
