//
//  QRScannerView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 17/12/24.
//

import SwiftUI
import UIKit
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var decodedQRData: String
    @Binding var isScanning: Bool
    var previewFrameSize = 300.0
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Unsupported Action")
            return vc
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
        } catch {
            return vc
        }
        
        let outputMetaData = AVCaptureMetadataOutput()
        captureSession.addOutput(outputMetaData)
        outputMetaData.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        outputMetaData.metadataObjectTypes = [.qr]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: previewFrameSize, height: previewFrameSize)
        previewLayer.videoGravity = .resizeAspectFill
        vc.view.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        context.coordinator.captureSession = captureSession
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isScanning {
            DispatchQueue.global(qos: .background).async {
                context.coordinator.captureSession?.startRunning()
            }
        } else {
            context.coordinator.captureSession?.stopRunning()
        }
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        var captureSession: AVCaptureSession?
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard
                let metaData = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                metaData.type == .qr,
                let decodedData = metaData.stringValue
            else { return }
                        
            parent.isScanning = false
            parent.decodedQRData = decodedData
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

//#Preview {
//    QRScannerView()
//}
