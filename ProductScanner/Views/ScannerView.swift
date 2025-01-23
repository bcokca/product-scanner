import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var scannerModel = ScannerViewModel()
    @State private var showAlert = false
    @State private var showProductDetail = false
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: scannerModel.session)
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            // Scanning overlay
            VStack(spacing: 0) {
                // Custom title bar
                ZStack {
                    Color.black.opacity(0.7)
                    Text("Scan Product")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .frame(height: 44)
                
                if !scannerModel.isCameraAuthorized {
                    Text("Camera access required")
                        .foregroundColor(.red)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                // Scan frame
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .frame(width: 250, height: 150)
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing: 16) {  // Group bottom elements with consistent spacing
                    // Status text
                    Text(scannerModel.statusMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(10)
                    
                    if scannerModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding(.bottom, 16)  // Add padding above tab bar background
                
                // Add spacing for tab bar with background
                Color.black.opacity(0.7)  // Semi-transparent background
                    .frame(height: 90)  // Increased height to cover tab bar area
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            scannerModel.requestCameraPermission()
        }
        .onDisappear {
            scannerModel.cleanup()
        }
        .alert("Scanner Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(scannerModel.errorMessage)
        }
        .onChange(of: scannerModel.errorMessage) { _, newValue in
            showAlert = !newValue.isEmpty
        }
        .onChange(of: scannerModel.scannedProduct) { _, product in
            if product != nil {
                showProductDetail = true
            }
        }
        .sheet(isPresented: $showProductDetail, onDismiss: {
            scannerModel.resetScanState()
        }) {
            if let product = scannerModel.scannedProduct {
                ProductDetailView(product: product)
            }
        }
    }
} 
