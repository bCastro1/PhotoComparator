//
//  CameraView.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 6/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
     var frontCamera: AVCaptureDevice?
     var rearCamera: AVCaptureDevice?
     var flashMode = AVCaptureDevice.FlashMode.off


     var currentCameraPosition: CameraPosition?
     var frontCameraInput: AVCaptureDeviceInput?
     var rearCameraInput: AVCaptureDeviceInput?
     
     var photoOutput: AVCapturePhotoOutput?
     var previewLayer: AVCaptureVideoPreviewLayer?
     
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var zoomFactor: CGFloat = 1.0
        
     public enum CameraPosition {
         case front
         case rear
     }
     
     enum CameraControllerError: Swift.Error {
             case captureSessionAlreadyRunning
             case captureSessionIsMissing
             case inputsAreInvalid
             case invalidOperation
             case noCamerasAvailable
             case unknown
         }
}


extension CameraController {
   //MARK: Prepping device for camera use
    func prepare(completionHandler: @escaping (Error?) -> Void){
        
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            //self.captureSession?.sessionPreset = .photo
        }
        
        
        //MARK: getting devices cameras
        func configureCaptureDevices() throws {
            //finding available cameras on device
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = (session.devices.compactMap { $0 })
            if cameras.count != 0 {
                for camera in cameras {
                    if camera.position == .front {
                        self.frontCamera = camera
                        
                    }
                    if camera.position == .back {
                        self.rearCamera = camera
                        try camera.lockForConfiguration()
                        
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
                
            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        //MARK: Config cameras
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }

                self.currentCameraPosition = .rear
            }

            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }

                self.currentCameraPosition = .front
            }
            
            else { throw CameraControllerError.noCamerasAvailable }
            
        }
        
        //MARK: Config output
        func configurePhotoOutput() throws {
           guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
           self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
        
           captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        
        
    }
    
    //MARK: Display photo preview
    func displayPreview(on view: UIView) throws {
       guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
    //        iv.contentMode = .scaleAspectFit

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.previewLayer?.connection?.videoOrientation = .portrait
    
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        let pinchZoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
        view.addGestureRecognizer(pinchZoomGesture)
        
        self.previewLayer?.frame = view.bounds
    }
    
    
    //MARK: Switch Cameras
    func switchCameras() throws{
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            let inputs = captureSession.inputs
           guard let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
               let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
        
           self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
           captureSession.removeInput(rearCameraInput)
        
           if captureSession.canAddInput(self.frontCameraInput!) {
               captureSession.addInput(self.frontCameraInput!)
        
               self.currentCameraPosition = .front
           }
        
           else { throw CameraControllerError.invalidOperation }
        }
        func switchToRearCamera() throws {
            let inputs = captureSession.inputs
            guard let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
               let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
        
           self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
           captureSession.removeInput(frontCameraInput)
        
           if captureSession.canAddInput(self.rearCameraInput!) {
               captureSession.addInput(self.rearCameraInput!)
        
               self.currentCameraPosition = .rear
           }
        
           else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()

        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    
    //MARK: Capture Image
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void){
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }


    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }

            guard let imageData = photo.fileDataRepresentation() else { return }
        
            let previewImage = UIImage(data: imageData)
        self.photoCaptureCompletionBlock?(previewImage, nil)

    }
    
    

    //MARK: Zoom gesture func
    @objc public func zoom(pinch: UIPinchGestureRecognizer) {
        guard let device = self.rearCamera else { return }
        func minMaxZoom(_ factor: CGFloat) -> CGFloat { return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor) }

          func update(scale factor: CGFloat) {
            do {
              try device.lockForConfiguration()
              defer { device.unlockForConfiguration() }
              device.videoZoomFactor = factor
            } catch {
              debugPrint(error)
            }
          }

          let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)

          switch pinch.state {
            case .began: fallthrough
            case .changed: update(scale: newScaleFactor)
            case .ended:
              zoomFactor = minMaxZoom(newScaleFactor)
              update(scale: zoomFactor)
            default: break
          }
    }
}

