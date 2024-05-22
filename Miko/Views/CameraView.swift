//
//  CameraView.swift
//  Miko
//
//  Created by David Zhang on 5/19/24.
//

import AVFoundation
import SwiftUI
import Vision

struct CameraView: UIViewControllerRepresentable {
    @Binding var searchText: String
    
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func updateSearchText(_ text: String) {
            DispatchQueue.main.async {
                self.parent.searchText = text
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
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var timer: Timer?
    var lastSampleBuffer: CMSampleBuffer?
    weak var coordinator: CameraView.Coordinator?
    var viewfinderIconView: UIImageView!
    
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
        
        // Start the timer to control capture interval
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(captureFrame), userInfo: nil, repeats: true)
        
        addViewfinderIconOverlay()
    }
    
    func addViewfinderIconOverlay() {
        let viewfinderIcon = UIImage(systemName: "viewfinder.rectangular") // Make sure to have the viewfinder.rectangular icon in your assets
        viewfinderIconView = UIImageView(image: viewfinderIcon)
        viewfinderIconView.translatesAutoresizingMaskIntoConstraints = false
        viewfinderIconView.contentMode = .scaleAspectFit
        viewfinderIconView.tintColor = .white // Set the color if needed
        view.addSubview(viewfinderIconView)
        
        // Size increased by 3 times, assuming the original size is 30x30
        let iconSize: CGFloat = 180
        
        NSLayoutConstraint.activate([
            viewfinderIconView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.5),
            viewfinderIconView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.35),
            viewfinderIconView.widthAnchor.constraint(equalToConstant: iconSize),
            viewfinderIconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }
    
    @objc func captureFrame() {
        guard let sampleBuffer = lastSampleBuffer else { return }
        processSampleBuffer(sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        lastSampleBuffer = sampleBuffer
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var requestOptions: [VNImageOption : Any] = [:]
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
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        DispatchQueue.main.async {
            self.view.subviews.forEach { subview in
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                if topCandidate.string.count > 4 {
                    self.highlightText(observation: observation)
                }
            }
        }
    }
    
    func highlightText(observation: VNRecognizedTextObservation) {
        guard let topCandidate = observation.topCandidates(1).first else { return }
        
        let recognizedText = topCandidate.string
        
        let xOffset: CGFloat = view.bounds.size.width
        let yOffset: CGFloat = view.bounds.size.height
        let transform = CGAffineTransform.identity
            .scaledBy(x: xOffset, y: -yOffset)
            .translatedBy(x: 0, y: -1)
        
        let rect = observation.boundingBox.applying(transform)
        
        // Calculate the center of the bounding box
        let centerX = rect.midX
        let centerY = rect.midY
        
        // Calculate the target area
        let targetX = view.bounds.width * 0.5
        let targetY = view.bounds.height * 0.35
        let toleranceX: CGFloat = 40.0 // Adjust tolerance as needed
        let toleranceY: CGFloat = 15.0 // Adjust tolerance as needed
        
        // Check if the center of the bounding box is within the target area
        if abs(centerX - targetX) <= toleranceX && abs(centerY - targetY) <= toleranceY {
            let label = UILabel(frame: rect)
            label.backgroundColor = UIColor.yellow.withAlphaComponent(0.7)
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.text = recognizedText
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 5
            label.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            
            view.addSubview(label)
        }
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        print("Label tapped: \(label.text ?? "")")
        
        // Perform any action you want when the label is tapped
        let alert = UIAlertController(title: "Text Selected", message: label.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        coordinator?.updateSearchText(label.text ?? "")
    }
}

#Preview {
    struct CameraView_Preview: View {
        @State private var searchText = "Preview Text"
        
        var body: some View {
            CameraView(searchText: $searchText)
        }
    }

    return CameraView_Preview()
}
