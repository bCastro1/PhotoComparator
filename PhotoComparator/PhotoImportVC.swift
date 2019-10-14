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

class PhotoImportVC: CollectionViewController {

    var coreDataContext: NSManagedObjectContext! = nil
    
    let imagePicker = UIImagePickerController()
    var importButtonDisplayPicker = ImportPhotos()
    var photoObjectArray:[PicturedObject] = []
    let photoSize = CGSize(width: 2000, height: 1500)
    var imageURL: URL!
    var newCollectionName: String = ""
    var UID: NSString = ""
    var uploadButton = UIBarButtonItem()
    //same uid for pictures of same collection
    
    //core data objects
    var collectionName_UIDs: [NSManagedObject] = []
    var ckRecordIDs: [NSManagedObject] = []

    var coreDataFunctions = CoreDataFunctions()
    var cloudKitFunctions = CloudKitFunctions()
    
    enum pageCompletionError: Error {
        case invalidPicture
        case invalidNameLength
    }
    
    
    //MARK: Operation type
    enum importOperationType {
        case newCollection
        case existingCollection
    }
    
    func photoUploadOperations(operation: importOperationType){
        switch operation {
        case .newCollection:
            //new, random uid
            UID = UUID().uuidString as NSString
            uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(newCollectionUploadButton))
            self.navigationItem.rightBarButtonItem = uploadButton
            self.setupImportPhotoButton()
            self.importButtonDisplayPicker.addTarget(self, action: #selector(newPhotoImportAction), for: .touchUpInside)
            
            break
        case .existingCollection:
            //UID should be passed from controller
            uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(existingCollectionUploadButtonPressed))
            self.navigationItem.rightBarButtonItem = uploadButton
            self.setupImportPhotoButton()
            self.importButtonDisplayPicker.addTarget(self, action: #selector(existingPhotoImportAction), for: .touchUpInside)
            break
        }
    }
    

    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)

        self.collectionView.register(PhotoImportCell.self, forCellWithReuseIdentifier: "PhotoImportCell")
    }
    
    //MARK: Start Actions
    func setupImportPhotoButton(){
        self.view.addSubview(importButtonDisplayPicker)
        importButtonDisplayPicker.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        self.importButtonDisplayPicker.heightAnchor.constraint(equalToConstant: 45).isActive = true
        self.importButtonDisplayPicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
        self.importButtonDisplayPicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.bringSubviewToFront(importButtonDisplayPicker)
        
    }
    
    @objc func newPhotoImportAction(){
        self.getNewCollectionNameFromUser()
    }
    
    @objc func existingPhotoImportAction(){
        self.selectPhotosFromLibrary()
        self.importButtonDisplayPicker.removeFromSuperview()
    }
    
    
    //MARK: Getting collection name
    @objc func getNewCollectionNameFromUser(){
        let prompt = UIAlertController(title: "New Collection", message: "Please input the name of your new photo collection", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            self.newCollectionName = textField.text ?? ""
            self.title = self.newCollectionName
            if (self.photoObjectArray.isEmpty){
                self.selectPhotosFromLibrary()
            }
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Collection Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(prompt, animated: true, completion: nil)
        self.importButtonDisplayPicker.removeFromSuperview()
    }
    
    //MARK: Selecting photos
    
    func selectPhotosFromLibrary(){
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 10
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in },
            deselect: { (asset: PHAsset) -> Void in },
            cancel: { (assets: [PHAsset]) -> Void in },
            finish: { (assets: [PHAsset]) -> Void in
                
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
        }, completion: nil)
    }

    //MARK: Cell Layout
    
    func setupCells(){
        //laying out selected photos to cells
        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 8), padding: .zero)
        let itemsToDisplay = self.photoObjectArray.map { PhotoImportViewModel($0)}
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: itemsToDisplay)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()

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

    
    //MARK: New Collection Upload
    
    @objc func newCollectionUploadButton() throws {
        do {
            try pageCompletionCheck_NewCollection()
            print("success!")
            print("string id: \(self.newCollectionName)")
        }
        catch pageCompletionError.invalidNameLength {
            print("error length: \(self.newCollectionName.count) ")
            let notice = UIAlertController(title: "Error", message: "Proposed group names must be between 6 and 36 characters.", preferredStyle: .alert)
            notice.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { handler in
                self.getNewCollectionNameFromUser()
            }))
            notice.addAction(UIAlertAction(title: "Cancel Upload", style: .destructive, handler: { handler in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(notice, animated: true, completion: nil)
        }
        catch pageCompletionError.invalidPicture {
            print("err: pic")
            showSimpleAlertWithTitle("Group Picture Error", message: "A group photo is required.", viewController: self)
        }
        catch {
            showSimpleAlertWithTitle("Error", message: "An internal error occurred. Please try again later.", viewController: self)
            print("err: unexpected")
        }
    }
    
    func pageCompletionCheck_NewCollection() throws {
        
        //character count between 6-24 chars
        guard newCollectionName.count <= 36 && newCollectionName.count >= 6 else {
            throw pageCompletionError.invalidNameLength
        }
        
        //user must upload images
        guard !photoObjectArray.isEmpty else {
            throw pageCompletionError.invalidPicture
        }
        
        //start upload

        cloudKitFunctions.uploadPhotoObjectArray(photoArray: photoObjectArray)

        coreDataFunctions.saveNewCollectionName(uid: self.UID, newCollectionName: self.newCollectionName)
        
        //getting timestamp id to save as ckrecordID as reference to folder name from cloudkit
        coreDataFunctions.saveNewRecordID(recordIdentifier: cloudKitFunctions.getTimestampID())

        self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: Existing Collection Upload
    @objc func existingCollectionUploadButtonPressed(){
        do {
            try pageCompletionCheck_ExistingCollection()
            print("success!")
            print("string id: \(self.newCollectionName)")
        }
        catch pageCompletionError.invalidPicture {
            print("err: pic")
            showSimpleAlertWithTitle("Group Picture Error", message: "Nothing to upload!", viewController: self)
        }
        catch {
            showSimpleAlertWithTitle("Error", message: "An internal error occurred. Please try again later.", viewController: self)
            print("err: unexpected")
        }
    }
    
    func pageCompletionCheck_ExistingCollection() throws {
        
        //user must upload images
        guard !photoObjectArray.isEmpty else {
            throw pageCompletionError.invalidPicture
        }
        
        //start upload
        cloudKitFunctions.uploadPhotoObjectArray(photoArray: photoObjectArray)

        self.navigationController?.popViewController(animated: true)
        
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
