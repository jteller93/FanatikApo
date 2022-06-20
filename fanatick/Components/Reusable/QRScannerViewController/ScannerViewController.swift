//
//  QRScannerView.swift
//  fanatick
//
//  Created by Yashesh on 10/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import AVFoundation
import UIKit

protocol QRScannerDelegate {
    func codeFound(_ string: String?)
}

class ScannerViewController: ViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: QRScannerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = true
        hasCloseButton = true
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        let frameImageView = UIImageView()
        frameImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frameImageView)
        frameImageView.image = UIImage.init(named: "qrCodeFrame")
        let imageSize = view.frame.size.width * 0.85
        NSLayoutConstraint.activate([
            frameImageView.widthAnchor.constraint(equalToConstant: imageSize),
            frameImageView.heightAnchor.constraint(equalToConstant: imageSize),
            frameImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            frameImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            ])
    }
    
    func failed() {
        let ac = UIAlertController(title: LocalizedString("scanning_not_supported", story: .general), message: LocalizedString("your_device_does_not_support_scanning_a_code_from_an_item_please_use_a_device_with_a_camera", story: .general), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: LocalizedString("buttonTitle_ok", story: .general), style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.codeFound(stringValue)
        }
        
        dismiss(animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
