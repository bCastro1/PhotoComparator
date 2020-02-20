//
//  Import_CameraPhotoHelpers.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/23/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation
import AVFoundation
import BSImagePicker
import Photos

extension PhotoImportVC {
    
    //MARK: Choose photo location prompt
    //camera or camera roll
    func promptSavedPhotosOrCamera(){
        
        let prompt = UIAlertController(title: "Photo Location", message: "Choose from photo roll or bring up camera now", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { handler in
            self.checkCameraStatus()
        }
        let photoRoll = UIAlertAction(title: "Saved Photos", style: .default) { handler in
            self.selectPhotosFromLibrary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { handler in
        }
        prompt.addAction(cameraAction)
        prompt.addAction(photoRoll)
        prompt.addAction(cancel)
        self.present(prompt, animated: true, completion: nil)
    }
    
    //MARK: Camera permission and usage
    func checkCameraStatus(){
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
            case .notDetermined:
                requestCameraPermission()
                break
            case .authorized:
                presentCamera()
                break
            case .restricted, .denied:
                cameraAccessNeeded()
                break
            default:
                break
        }
    }
    
    func requestCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
                self.presentCamera()
        })
    }
    
    //MARK: Present cam if possible
    func presentCamera(){
        #if targetEnvironment(simulator)
            showSimpleAlertWithTitle("Error", message: "Cannot open the camera using a simulator", viewController: self)
            self.importButtonDisplayPicker.isHidden = false
        #else
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .camera
            photoPicker.delegate = self
            self.present(photoPicker, animated: true, completion: nil)
        #endif
        
    }
    
    //MARK: Cam permission
    func cameraAccessNeeded(){
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
            let alert = UIAlertController(title: "Need Camera Access", message: "Camera access is required to make full use of this app.",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
         guard let selectedImage = info[.originalImage] as? UIImage else {
             fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
         }
        let picturedObject = PicturedObject(
            date: NSDate(),
            photo: selectedImage,
            id: self.UID)
        self.photoObjectArray.append(picturedObject)
        self.photoObjectArray.sort(by: { $0.date.compare($1.date as Date) == ComparisonResult.orderedAscending })
        self.setupCells()
        dismiss(animated: true, completion: nil)
     }
    
    //MARK: Selecting photos
    
    func selectPhotosFromLibrary(){
        let imagePicker = ImagePickerController()
        imagePicker.doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button title"), style: .done, target: nil, action: nil)
        //    public var doneButton: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BSImagePicker.Done", comment: "Done button title"), style: .done, target: nil, action: nil)

        
        presentImagePicker(imagePicker, select: { (asset) in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { (asset) in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets) in
            self.importButtonDisplayPicker.isHidden = false
        }, finish: { (assets) in
            for pic in assets {
                guard let creationDate = pic.creationDate else {return}
                guard let image = self.getImageFromPHAsset(pic, size: self.photoSize, deliverMode: .highQualityFormat) else {return}

                let picturedObject = PicturedObject(
                    date: creationDate as NSDate,
                    photo: image,
                    id: self.UID)

                self.photoObjectArray.append(picturedObject)
            }
            //sorting: oldest first
            self.photoObjectArray.sort(by: { $0.date.compare($1.date as Date) == ComparisonResult.orderedAscending })
            self.setupCells()
        })
    }
    
    //MARK: Photo helper function
    
    func getImageFromPHAsset(_ asset:PHAsset,size:CGSize,deliverMode:PHImageRequestOptionsDeliveryMode)->UIImage?{
        
        var returnImage:UIImage? = nil
        
        let requestImageOption = PHImageRequestOptions()
        
        requestImageOption.deliveryMode = deliverMode
        
        requestImageOption.isSynchronous = true
        
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize:size, contentMode:PHImageContentMode.default, options: requestImageOption) { (image:UIImage?, _) in
            
            returnImage = image
        }
        return returnImage
    }
}
