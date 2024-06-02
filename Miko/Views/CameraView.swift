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
    @Binding var isFirstEverCameraPermissionRequest: Bool {
        didSet {
            saveIsFirstEverCameraPermissionRequest()
        }
    }
    @Binding var selectedSearchLanguages: [SearchLanguage]
    
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
        
        func updateIsFirstEverCameraPermissionRequest() {
            DispatchQueue.main.async {
                self.parent.isFirstEverCameraPermissionRequest = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.coordinator = context.coordinator
        cameraViewController.selectedSearchLanguages = selectedSearchLanguages.map { $0.rawValue }
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
            
            cameraViewController.selectedSearchLanguages = selectedSearchLanguages.map { $0.rawValue }
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
        
        self.coordinator?.updateIsFirstEverCameraPermissionRequest()
        
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
        addSettingsIconOverlay()
        addMenuIconOverlay()
        
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
            print("CAMERA CAPTURE START")
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        } else {
            print("CAMERA CAPTURE NOT STARTED, SHEET NOT AT TEST")
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
    
    func addSettingsIconOverlay() {
        let settingsIcon = UIImage(systemName: "switch.2")
        
        // Create a container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = true
        view.addSubview(containerView)
        
        // Create the icon view
        settingsIconView = UIImageView(image: settingsIcon)
        settingsIconView.translatesAutoresizingMaskIntoConstraints = false
        settingsIconView.contentMode = .scaleAspectFit
        settingsIconView.tintColor = .white
        containerView.addSubview(settingsIconView)
        
        let iconSize: CGFloat = 30
        let touchAreaSize: CGFloat = 60 // Increase this value to make the touch area larger
        
        // Constraints for the container view
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - (touchAreaSize * (2/3))),
            containerView.widthAnchor.constraint(equalToConstant: touchAreaSize),
            containerView.heightAnchor.constraint(equalToConstant: touchAreaSize)
        ])
        
        // Center the icon view inside the container view
        NSLayoutConstraint.activate([
            settingsIconView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            settingsIconView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - iconSize),
            settingsIconView.widthAnchor.constraint(equalToConstant: iconSize),
            settingsIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        // Add tap gesture recognizer to the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingsIconTapped))
        containerView.addGestureRecognizer(tapGesture)
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
        let touchAreaSize: CGFloat = 60 // Increase this value to make the touch area larger
        
        // Constraints for the container view
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - (touchAreaSize * (2/3))),
            containerView.widthAnchor.constraint(equalToConstant: touchAreaSize),
            containerView.heightAnchor.constraint(equalToConstant: touchAreaSize)
        ])
        
        // Center the icon view inside the container view
        NSLayoutConstraint.activate([
            menuIconView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -75),
            menuIconView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.bounds.height * 0.5) - iconSize),
            menuIconView.widthAnchor.constraint(equalToConstant: iconSize),
            menuIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        // Add tap gesture recognizer to the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuIconTapped))
        containerView.addGestureRecognizer(tapGesture)
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
            self.captureSession.stopRunning()
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
