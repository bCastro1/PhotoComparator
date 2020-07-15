//
//  PhotoImportVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/19/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import CloudKit
import CoreData
import AVFoundation

class PhotoImportVC: CollectionViewController, CoreDataSaveProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var isFinished: Bool = false
    var progressTotal: Int = 0

    
    let imagePicker = UIImagePickerController()
    var importButtonDisplayPicker = ImportPhotos()
    var photoObjectArray:[PicturedObject] = []
    var mergedPhotoToUpload: UIImage!
    var shouldWaitToSetupCells: Bool = false //wait until page is loaded to call setupCells()
    let photoSize = CGSize(width: 2000, height: 1500)
    var imageURL: URL!
    var newCollectionName: String = ""
    var UID: NSString = ""
    var uploadButton = UIBarButtonItem()
    var progressView = UploadProgressView()
    var tutorialView = Tutorial_View()
    var controllersToPop: Int = 2


    var uploadOperationType = importOperationType.newCollection
    
    //same uid for pictures of same collection
    
    //core data objects
    var collectionName_UIDs: [NSManagedObject] = []
    var ckRecordIDs: [NSManagedObject] = []

    
    //MARK: Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init()
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum pageCompletionError: Error {
        case invalidPicture
        case invalidNameLength
    }
    
    
    //MARK: Operation type
    enum importOperationType {
        case newCollection
        case existingCollection
        case singlePhoto_Existing_CollectionAddition
        case singlePhoto_New_CollectionAddition
    }
    
    func photoUploadOperations(operation: importOperationType, uid: NSString?){
        uploadOperationType = operation
        if let UID = uid {
            self.UID = UID
        } else { self.UID = UUID().uuidString as NSString}
        
        switch operation {
        case .newCollection:
            //new, random uid
            newCollectionUpload(UID: self.UID)
            break
            
        case .existingCollection:
            //UID should be passed from controller
            existingCollectionUpload(UID: self.UID)
            break
        
        case .singlePhoto_Existing_CollectionAddition:
            //name, UID is passed from previous controller -> photoObjectArray, newCollectionName, UID
            //same as existing colleciton
            merged_ExistingCollectionUpload(UID: self.UID)
            break
            
        case .singlePhoto_New_CollectionAddition:
            //name, uid passed from previous controller
            merged_NewCollectionUpload(UID: self.UID)
            break
        }
    }
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .dynamicBackground()
        
        coreDataFunctions?.delegate = self
        cloudkitOperations?.delegate = self
        self.collectionView.register(PhotoImportCell.self, forCellWithReuseIdentifier: "PhotoImportCell")
        self.setupProgressView()
        tutorialViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Import"
        if (shouldWaitToSetupCells){
            self.setupCells()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    func setupProgressView(){
        progressView.isHidden = true
        progressView.alpha = 0.8
        progressView.progress(currentIdx: 1, total: 1)
        self.view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        progressView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -50).isActive = true
        progressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    //MARK: Start Actions
    func setupImportPhotoButton(){
        self.view.addSubview(importButtonDisplayPicker)
        self.importButtonDisplayPicker.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        self.importButtonDisplayPicker.heightAnchor.constraint(equalToConstant: 45).isActive = true
        self.importButtonDisplayPicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
        self.importButtonDisplayPicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.bringSubviewToFront(importButtonDisplayPicker)
        
    }
    
    @objc func newPhotoImportAction(){
        if (newCollectionName == ""){
            self.getNewCollectionNameFromUser()
        }
        else {
            self.promptSavedPhotosOrCamera()
        }
    }
    
    @objc func existingPhotoImportAction(){
        self.promptSavedPhotosOrCamera()
    }
    

    
    //MARK: Getting collection name
    @objc func getNewCollectionNameFromUser(){
        let prompt = UIAlertController(title: "New Album", message: "Please input the name of your new photo album", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            self.newCollectionName = textField.text ?? ""
            self.navigationItem.title = self.newCollectionName
            if (self.photoObjectArray.isEmpty){
                self.promptSavedPhotosOrCamera()
            }
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Album Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { handler in
                self.importButtonDisplayPicker.isHidden = false
        }))
        self.present(prompt, animated: true, completion: nil)
        self.importButtonDisplayPicker.isHidden = true
    }
    
    
    //MARK: Tutorial View
    func tutorialViewSetup(){
        if (UserDefaults.standard.getTutorialDefault(tutorialType: .album) == "show"){

            tutorialView = Tutorial_View(frame: self.view.frame, tutorialTextID: .addPhotoToAlbum)
            tutorialView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tutorialView)
            self.tutorialView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.tutorialView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.tutorialView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tutorialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTutorialView))
            self.tutorialView.addGestureRecognizer(tapGesture)
            
            importButtonDisplayPicker.isEnabled = false
            importButtonDisplayPicker.alpha = 0.6
            self.view.bringSubviewToFront(tutorialView)
        }
    }
    
    @objc func dismissTutorialView(){
        importButtonDisplayPicker.alpha = 1
        importButtonDisplayPicker.isEnabled = true
        self.tutorialView.removeFromSuperview()
    }


    //MARK: setupCells
    
    func setupCells(){
        //laying out selected photos to cells
        self.progressTotal = self.photoObjectArray.count
        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 8), padding: .zero)
        let itemsToDisplay = self.photoObjectArray.map { PhotoImportViewModel($0)}
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: itemsToDisplay)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }



    //MARK: UserDefault StorageType
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
    
    //MARK: Status Bar Protocol
    func saveProgess(progressInt: Int) {
        DispatchQueue.main.async {
            print("progress: (\(progressInt+1)/\(self.progressTotal))")
            self.progressView.progress(currentIdx: progressInt, total: self.progressTotal)
            if (progressInt+1 == self.progressTotal){
                self.uploadFinishedPromptNextAction()
            }
        }
    }
    
    func uploadFinishedPromptNextAction(){
        let finishNotice = UIAlertController(title: "Saved!", message: "Your photo was successfully uploaded", preferredStyle: .alert)
        
        let uploadMoreAction = UIAlertAction(title: "Upload more photos", style: .default, handler: { alert -> Void in
            self.resetUI()
        })
        
        let backToCollageAction = UIAlertAction(title: "Exit", style: .default, handler: { alert -> Void in
            self.navigationController?.popViewControllers(controllersToPop: self.controllersToPop, animated: true)
        })
        
        let backToAlbumsAction = UIAlertAction(title: "Go to albums page", style: .default, handler: { alert -> Void in
            self.navigationController?.popToRootViewController(animated: true)
            self.resetUI()
        })

        if (mergedPhotoToUpload == nil){
            //if merged photo is nil, that means they are uploading from main tab bar option
            finishNotice.addAction(uploadMoreAction)
            finishNotice.addAction(backToAlbumsAction)
        }
        else {
            //if not nil, user is uploading from the collage page
            finishNotice.addAction(backToCollageAction)
        }
        
        self.present(finishNotice, animated: true, completion: nil)
    }
    
    deinit {
        print("photo upload screen de init")
    }
    
    func resetUI(){
        self.photoObjectArray.removeAll()
        self.setupCells()
        self.importButtonDisplayPicker.isHidden = false
        self.progressView.isHidden = true
        self.newCollectionName = ""
        self.navigationItem.title = self.newCollectionName
    }
}





   //MARK: END OF UPLOAD..?
   /*
    -Clean up URL and unset images-
 
    @IBAction func dismiss(sender: AnyObject) {
        if let url = imageURL {
            let fileManager = NSFileManager()
            if fileManager.fileExistsAtPath(url.absoluteString!) {
                fileManager.removeItemAtURL(url, error: nil)
            }
        }
     
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func unsetImage(sender: AnyObject) {
        imageView.image = nil
     
        imageView.hidden = true
        btnRemoveImage.hidden = true
        btnSelectPhoto.hidden = false
     
        imageURL = nil
    }
    */
