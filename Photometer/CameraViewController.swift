//
//  ViewController.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 02.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import RealmSwift
import SwiftOCR

enum CameraViewType {
    case meter
    case values
}

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewFinder: UIView!
    
    var viewType: CameraViewType = .meter {
        didSet {
            viewFinder.isHidden = viewType == .meter
        }
    }
    var stillImageOutput: AVCaptureStillImageOutput!
    let captureSession = AVCaptureSession()
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewFinder.isHidden = true
        DispatchQueue.global().async {
            if(self.device != nil){
                self.beginSession()
            }
        }
    }
    
    // MARK: AVFoundation
    
    func beginSession() {
        self.stillImageOutput = AVCaptureStillImageOutput()
        if UIDevice.current.userInterfaceIdiom == .phone && max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) < 568.0 {
            self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        } else {
            self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
        self.captureSession.addOutput(self.stillImageOutput)
        
        DispatchQueue.global().async {
            do{
                self.captureSession.addInput(try AVCaptureDeviceInput(device: self.device))
            } catch {
                print("AVCaptureDeviceInput Error")
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer?.frame.size = self.cameraView.frame.size
            previewLayer?.frame.origin = CGPoint.zero
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            do {
                try self.device?.lockForConfiguration()
                
                self.device?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                self.device?.focusMode = .continuousAutoFocus
                
                self.device?.unlockForConfiguration()
                
            } catch {
                print("captureDevice?.lockForConfiguration() denied")
            }
            
            //Set initial Zoom scale
            
            do {
                let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                try device?.lockForConfiguration()
                
                let zoomScale:CGFloat = 2.5
                
                if zoomScale <= (device?.activeFormat.videoMaxZoomFactor)! {
                    device?.videoZoomFactor = zoomScale
                }
                
                device?.unlockForConfiguration()
                
            } catch {
                print("captureDevice?.lockForConfiguration() denied")
            }
            
            DispatchQueue.main.async(execute: {
                self.cameraView.layer.addSublayer(previewLayer!)
                self.captureSession.startRunning()
            })
        }
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        self.stillImageOutput.captureStillImageAsynchronously(from: self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo)) { (buffer, error) -> Void in
            guard let buffer = buffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), let image = UIImage(data: imageData) else {
                return
            }
            switch self.viewType {
            case .meter:
                self.recognizeMeter(image: image)
            case .values:
                self.recognizeValues(image: image)
            }
        }
    }
    
    private func recognizeMeter(image: UIImage) {
        let realm = try! Realm()
        let meters = Array(realm.objects(Meter.self))
        var recognizedIndex = 0
        var max = 0.0
        for (index, meter) in meters.enumerated() {
            let result = OpenCV.compare(image, with: meter.image)
            print("Reult for meter name: \(meter.name) \(result)")
            if (result?.first?.doubleValue)! > max {
                recognizedIndex = index
                max = (result?.first?.doubleValue)!
            }
        }
        DispatchQueue.main.async {
            self.show(meterName: meters[recognizedIndex].name)
        }
    }
    
    private func recognizeValues(image: UIImage) {
        let croppedImage = self.cropImage(image)
        
        let ocrInstance = SwiftOCR()
        ocrInstance.recognize(croppedImage) { recognizedString in
            DispatchQueue.main.async(execute: {
                self.show(meterValue: recognizedString)
            })
        }
    }
    
    func show(meterValue: String) {
        let alert = UIAlertController(title: "Recognized value", message: "\(meterValue)", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = meterValue
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.viewType = .meter
        }))
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
        self.tabBarController?.show(alert, sender: self)
    }
    
    func show(meterName: String) {
        let alert = UIAlertController(title: "Recognized meter", message: "\(meterName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.viewType = .values
        }))
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
        self.tabBarController?.show(alert, sender: self)
    }
    
    func show(result: [NSNumber]) {
        let alert = UIAlertController(title: "Result", message: "\(result)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alert, sender: self)
    }
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        do {
            try device!.lockForConfiguration()
            var zoomScale = CGFloat(slider.value * 10.0)
            
            if zoomScale < 1 {
                zoomScale = 1
            } else if zoomScale > (device?.activeFormat.videoMaxZoomFactor)! {
                zoomScale = (device?.activeFormat.videoMaxZoomFactor)!
            }
            
            device?.videoZoomFactor = zoomScale
            device?.unlockForConfiguration()
            
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
    }
    
    // MARK: Image Processing
    
    func cropImage(_ image: UIImage) -> UIImage {
        
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        let imageOrientation = image.imageOrientation
        
        var degree:CGFloat
        
        switch imageOrientation {
        case .right, .rightMirrored:    degree = 90
        case .left, .leftMirrored:      degree = -90
        case .up, .upMirrored:          degree = 180
        case .down, .downMirrored:      degree = 0
        }
        
        let cropSize = CGSize(width: 400, height: 110)
        
        //Downscale
        
        let cgImage = image.cgImage!
        
        let width = cropSize.width
        let height = image.size.height / image.size.width * cropSize.width
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        
        context!.interpolationQuality = CGInterpolationQuality.none
        
        // Rotate the image context
        context?.rotate(by: degreesToRadians(degree));
        
        // Now, draw the rotated/scaled image into the context
        context?.scaleBy(x: -1.0, y: -1.0)
        
        //Crop
        
        switch imageOrientation {
        case .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: -height, y: 0, width: height, height: width))
        case .left, .leftMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: -width, width: height, height: width))
        case .up, .upMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        case .down, .downMirrored:
            context?.draw(cgImage, in: CGRect(x: -width, y: -height, width: width, height: height))
        }
        
        let scaledCGImage = context?.makeImage()?.cropping(to: CGRect(x: 0, y: CGFloat((height - cropSize.height)/2.0), width: cropSize.width, height: cropSize.height))
        
        return UIImage(cgImage: scaledCGImage!)
        
    }

    
}
