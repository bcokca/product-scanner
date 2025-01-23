import AVFoundation
import SwiftUI

@MainActor
class ScannerViewModel: NSObject, ObservableObject {
    @Published var statusMessage = "Position barcode within frame"
    @Published var errorMessage = ""
    @Published var scannedProduct: Product?
    @Published var isLoading = false
    @Published var isCameraAuthorized = false
    
    let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let productService = ProductService()
    private var isConfigured = false
    private var canScan = true
    private var lastScannedBarcode: String?
    
    override init() {
        super.init()
        print("ScannerViewModel initialized")
    }
    
    func requestCameraPermission() {
        guard !isConfigured else {
            print("Camera already configured")
            return
        }
        
        print("Requesting camera permission...")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access already authorized")
            self.isCameraAuthorized = true
            setupCaptureSession()
        case .notDetermined:
            print("Camera access not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        print("Camera access granted")
                        self?.isCameraAuthorized = true
                        self?.setupCaptureSession()
                    } else {
                        print("Camera access denied")
                        self?.errorMessage = "Camera access denied"
                        self?.isCameraAuthorized = false
                    }
                }
            }
        case .denied:
            print("Camera access denied")
            self.errorMessage = "Camera access denied. Please enable camera access in Settings"
            self.isCameraAuthorized = false
        case .restricted:
            print("Camera access restricted")
            self.errorMessage = "Camera access is restricted"
            self.isCameraAuthorized = false
        @unknown default:
            print("Unknown camera authorization status")
            self.errorMessage = "Unknown camera authorization status"
            self.isCameraAuthorized = false
        }
    }
    
    private func setupCaptureSession() {
        guard !isConfigured else {
            print("Session already configured")
            return
        }
        
        statusMessage = "Setting up camera..."
        print("Starting camera setup...")
        
        if session.isRunning {
            print("Stopping existing session")
            session.stopRunning()
        }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            let error = "No camera detected"
            print(error)
            errorMessage = error
            return
        }
        
        do {
            print("Attempting to create video input...")
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            session.beginConfiguration()
            
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("Camera input added successfully")
                statusMessage = "Camera input added..."
            } else {
                let error = "Camera is not available for capture"
                print(error)
                throw NSError(domain: "Scanner", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128]
                print("Camera output added successfully")
                statusMessage = "Camera output added..."
            } else {
                let error = "Cannot add metadata output"
                print(error)
                throw NSError(domain: "Scanner", code: 2, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            session.commitConfiguration()
            isConfigured = true
            print("Session configuration committed")
            
            Task.detached { [weak self] in
                print("Starting capture session...")
                self?.session.startRunning()
                await MainActor.run {
                    self?.statusMessage = "Position barcode within frame"
                }
            }
        } catch {
            print("Camera setup failed with error: \(error.localizedDescription)")
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
            statusMessage = "Camera setup failed"
        }
    }
    
    private func lookupProduct(barcode: String) {
        guard !isLoading && canScan && lastScannedBarcode != barcode else { return }
        
        isLoading = true
        canScan = false
        lastScannedBarcode = barcode
        statusMessage = "Looking up product: \(barcode)"
        
        Task {
            do {
                let product = try await productService.fetchProduct(barcode: barcode)
                self.scannedProduct = product
                self.statusMessage = "Found: \(product.name)"
            } catch {
                self.errorMessage = error.localizedDescription
                self.statusMessage = "Position barcode within frame"
            }
            
            self.isLoading = false
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.canScan = true
        }
    }
    
    func cleanup() {
        if session.isRunning {
            session.stopRunning()
        }
        isConfigured = false
        isLoading = false
        canScan = true
        lastScannedBarcode = nil
        statusMessage = "Position barcode within frame"
        errorMessage = ""
        scannedProduct = nil
    }
    
    func resetScanState() {
        isLoading = false
        canScan = true
        lastScannedBarcode = nil
        statusMessage = "Position barcode within frame"
        errorMessage = ""
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if let barcodeValue = metadataObject.stringValue {
                statusMessage = "Barcode detected: \(barcodeValue)"
                lookupProduct(barcode: barcodeValue)
            } else {
                statusMessage = "Invalid barcode format"
            }
        }
    }
} 
