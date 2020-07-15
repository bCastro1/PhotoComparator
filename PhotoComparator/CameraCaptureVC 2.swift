//
//  CameraCaptureVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 6/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraCaptureVC: UIViewController {

    var pho: AVCaptureOutput?
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    var cameraController = CameraController()
    var shouldViewPhoto: Bool = false
    var showComparisonPhoto: Bool = false
    var passedAlbumUID: NSString?
    var passedAlbumName: String?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.transparencyButton.isHidden = true
        self.transparencyButton.isEnabled = false
    }
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, comparisonPhoto: UIImage, AlbumUID: NSString, AlbumName: String){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.transparentImageView.image = comparisonPhoto
        self.passedAlbumUID = AlbumUID
        self.passedAlbumName = AlbumName
        self.transparencyButton.isHidden = false
        self.transparencyButton.isEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: UI Components
    var preview: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageDisplayView: UIImageView = {
        var iv = UIImageView()
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var transparentImageView: UIImageView = {
        var iv = UIImageView()
        iv.isHidden = true
        iv.alpha = 0.5
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var flashButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.FlashOff, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.addTarget(self, action: #selector(flashButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var captureButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.AndroidRadioButtonOn, color: UIColor.white, iconSize: 100, imageSize: CGSize(width: 100, height: 100)), for: .normal)
        button.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var flipCameraButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSReverseCameraOutline, color: UIColor.white, iconSize: 50, imageSize: CGSize(width: 50, height: 50)), for: .normal)
        button.addTarget(self, action: #selector(flipCameraButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var transparencyButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.Images, color: UIColor.white, iconSize: 50, imageSize: CGSize(width: 50, height: 50)), for: .normal)
        button.addTarget(self, action: #selector(transparencyButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var exitButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSClose, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.isHidden = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var retakePhotoButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSUndo, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.addTarget(self, action: #selector(retakePhotoAction), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var savePhotoButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSDownloadOutline, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.addTarget(self, action: #selector(savePhotoButtonPressed), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}

extension CameraCaptureVC {
    //MARK: Functions
    

    
            //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        setupLayout()
        
        
        func configureCameraController(){
            cameraController.prepare {(error) in
                   if let error = error {
                       print(error)
                   }
            
                   try? self.cameraController.displayPreview(on: self.preview)
               }
        }
        configureCameraController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK: Button actions
    @objc func flashButtonPressed(){
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            flashButton.setImage(UIImage.imageWithIonicon(.FlashOff, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        }
        else {
            cameraController.flashMode = .on
            flashButton.setImage(UIImage.imageWithIonicon(.Flash, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        }
    }
    
    //MARK: Capture
    @objc func captureButtonPressed(){
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            self.imageDisplayView.image = image
            self.shouldViewPhoto = true
            self.togglePhotoViewMode()
//            try? PHPhotoLibrary.shared().performChangesAndWait {
//                PHAssetChangeRequest.creationRequestForAsset(from: image)
//
//            }
        }
    }

    //MARK: Transparency
    @objc func transparencyButtonPressed(){
        showComparisonPhoto.toggle()
        if(showComparisonPhoto){
            transparentImageView.isHidden = false
        }
        else {
            transparentImageView.isHidden = true
        }
    }
    
    //MARK: Flip cam
    @objc func flipCameraButtonPressed(){
            do {
               try cameraController.switchCameras()
           }
        
           catch {
               print(error)
           }
        
           switch cameraController.currentCameraPosition {
           case .some(.front):
            flipCameraButton.setImage(UIImage.imageWithIonicon(.iOSReverseCamera, color: UIColor.white, iconSize: 50, imageSize: CGSize(width: 50, height: 50)), for: .normal)

           case .some(.rear):
            flipCameraButton.setImage(UIImage.imageWithIonicon(.iOSReverseCameraOutline, color: UIColor.white, iconSize: 50, imageSize: CGSize(width: 50, height: 50)), for: .normal)

           case .none:
               return
           }
    }
    
    //MARK: Save photo
    @objc func savePhotoButtonPressed(){

        let notice = UIAlertController(title: "Save Photo", message: "Where would you like to save this photo?", preferredStyle: .actionSheet)
        let saveToCameraRoll = UIAlertAction(title: "Save to Camera Roll", style: .default) { handler in
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: self.imageDisplayView.image!)
            }
        }
        let saveToAlbums = UIAlertAction(title: "Save to an Album", style: .default) { handler in
            let collectionSelectorVC = CollectionListVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
            collectionSelectorVC.imageToSave = self.imageDisplayView.image
            self.navigationController?.pushViewController(collectionSelectorVC, animated: true)
        }
        
        //only available if passed from existing album
        if let uid = passedAlbumUID, let name = passedAlbumName {
            let saveToPassedAlbum = UIAlertAction(title: "Save to \(name)", style: .default) { handler in
                let photoImportVC = PhotoImportVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
                  
                photoImportVC.mergedPhotoToUpload = self.imageDisplayView.image
                photoImportVC.photoUploadOperations(operation: .singlePhoto_Existing_CollectionAddition, uid: uid)
                photoImportVC.newCollectionName = name
                photoImportVC.title = "\(name)"
                photoImportVC.controllersToPop = 1
                photoImportVC.shouldWaitToSetupCells = true
                self.navigationController?.pushViewController(photoImportVC, animated: true)
            }
            notice.addAction(saveToPassedAlbum)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        notice.addAction(saveToCameraRoll)
        notice.addAction(saveToAlbums)
        notice.addAction(cancel)
        
        self.present(notice, animated: true, completion: nil)
    }
    
    //MARK: Reset UIs
    @objc func retakePhotoAction(){
        self.shouldViewPhoto = false
        togglePhotoViewMode()
    }
    
    @objc func dismissVC(){
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: toggle view photo
    func togglePhotoViewMode(){
        if (shouldViewPhoto){
            self.imageDisplayView.isHidden = false
            
            self.preview.isHidden = true
            self.exitButton.isHidden = true
            self.captureButton.isHidden = true
            self.flashButton.isHidden = true
            self.flipCameraButton.isHidden = true
            self.transparencyButton.isHidden = true
            
            self.transparencyButton.isEnabled = false
            self.flipCameraButton.isEnabled = false
            self.flashButton.isEnabled = false
            self.captureButton.isEnabled = false
            self.exitButton.isEnabled = false
            
            self.retakePhotoButton.isHidden = false
            self.retakePhotoButton.isEnabled = true
            self.savePhotoButton.isHidden = false
            self.savePhotoButton.isEnabled = true
        }
        else {
            self.imageDisplayView.isHidden = true
            
            self.preview.isHidden = false
            self.exitButton.isHidden = false
            self.captureButton.isHidden = false
            self.flashButton.isHidden = false
            self.flipCameraButton.isHidden = false
            self.transparencyButton.isHidden = false
            
            self.transparencyButton.isEnabled = true
            self.flipCameraButton.isEnabled = true
            self.flashButton.isEnabled = true
            self.captureButton.isEnabled = true
            self.exitButton.isEnabled = true
            
            self.retakePhotoButton.isHidden = true
            self.retakePhotoButton.isEnabled = false
            self.savePhotoButton.isHidden = true
            self.savePhotoButton.isEnabled = false
        }
    }
    
    //MARK: Set view constraints
    func setupLayout(){
        
        self.view.addSubview(preview)
        preview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        preview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        preview.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        preview.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        self.view.addSubview(flashButton)
        flashButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        flashButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        flashButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        
        self.view.addSubview(exitButton)
        exitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        exitButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.preview.addSubview(transparentImageView)
        transparentImageView.centerYAnchor.constraint(equalTo: preview.centerYAnchor).isActive = true
        transparentImageView.centerXAnchor.constraint(equalTo: preview.centerXAnchor).isActive = true
        transparentImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        transparentImageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        self.view.addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        self.view.addSubview(retakePhotoButton) //same spot as exit button, only this is hidden until a pic is taken
        retakePhotoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        retakePhotoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        retakePhotoButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        retakePhotoButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.view.addSubview(imageDisplayView)
        imageDisplayView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageDisplayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageDisplayView.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        imageDisplayView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        self.view.addSubview(transparencyButton)
        transparencyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        transparencyButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        transparencyButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        transparencyButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        
        self.view.addSubview(flipCameraButton)
        flipCameraButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        flipCameraButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        flipCameraButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        flipCameraButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        self.view.addSubview(savePhotoButton) //same spot as flip cam button, only this is hidden until a pic is taken
        savePhotoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        savePhotoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        savePhotoButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        savePhotoButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        

        
        self.view.bringSubviewToFront(self.imageDisplayView)
        self.view.bringSubviewToFront(self.retakePhotoButton)
        self.view.bringSubviewToFront(self.savePhotoButton)
    }
}
