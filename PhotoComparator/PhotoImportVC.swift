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

    let imagePicker = UIImagePickerController()
    var photoObjectArray:[PicturedObject] = []
    let photoSize = CGSize(width: 2000, height: 1500)
    var imageURL: URL!
    var newCollectionName: String = ""
    var UID = UUID().uuidString as NSString
    //same uid for pictures of same collection
    
    //core data objects
    var firstObjectTimestampIDforCoreData: String = ""
    var collectionName_UIDs: [NSManagedObject] = []
    var ckRecordIDs: [NSManagedObject] = []

    enum pageCompletionError: Error {
        case invalidPicture
        case invalidNameLength
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)
        self.title = "New Collection"
        let uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadButtonPressed))
        self.navigationItem.rightBarButtonItem = uploadButton
        self.collectionView.register(PhotoImportCell.self, forCellWithReuseIdentifier: "PhotoImportCell")
        
        
        getNewCollectionNameFromUser()
    }
    
    //MARK: 1. Getting collection name
    func getNewCollectionNameFromUser(){
        let prompt = UIAlertController(title: "New Collection", message: "Please input the name of your new photo collection", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            self.newCollectionName = textField.text ?? ""
            self.title = self.newCollectionName
            self.selectPhotosFromLibrary()
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Collection Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(prompt, animated: true, completion: nil)
    }
    
    //MARK: 2. Selecting photos and populating collection view
    
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

    func setupCells(){
        //laying out selected photos to cells
        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 8), padding: .zero)
        let itemsToDisplay = self.photoObjectArray.map { [weak self] photoObjectArray in
            PhotoImportViewModel(photoObjectArray)
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: itemsToDisplay)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()

        //preparePhotoAsURL()
    }
    
    //MARK: 3. Cloudkit object upload
    
    func preparePhotoAsURL(){
        //upload start
        for (index, picturedObject) in photoObjectArray.enumerated() {
            
            let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            
            let imageData = picturedObject.photo.jpegData(compressionQuality: 0.8)
            let path = documentsDirectoryPath.appendingPathComponent("tempImgName.jpg")
            imageURL = URL(fileURLWithPath: path)
            do {
                try imageData?.write(to: imageURL as URL)
                saveSaveURL_CK(picturedObject: picturedObject, index: index)
            } catch let error as NSError {
                showSimpleAlertWithTitle("Error", message: "An internal error occurred on photo upload. Please try again later.", viewController: self)
                print("photo upload write to URL Failed. Underlying error \(error)")
            }
        }
    }
    
    func saveSaveURL_CK(picturedObject: PicturedObject, index: Int){
        let timestampAsString = String(format: "%f", Date.timeIntervalSinceReferenceDate)
        //creating uid for CKRecord
        var timestampParts = timestampAsString.components(separatedBy: ".")
        timestampParts[0] += "-\(index)"
        let noteID = CKRecord.ID(recordName: timestampParts[0])
        let picturedObjectRecord = CKRecord(recordType: "PicturedObject", recordID: noteID)
        picturedObjectRecord.setValue(picturedObject.id, forKey: "id")
        picturedObjectRecord.setValue(picturedObject.date, forKey: "date")
        
        if let url = imageURL {
            let imageAsset = CKAsset(fileURL: url)
            picturedObjectRecord.setObject(imageAsset, forKey: "photo")
        }
        else {
            guard let fileURL = Bundle.main.url(forResource: "no_image", withExtension: "png") else { return }
            let imageAsset = CKAsset(fileURL: fileURL)
            picturedObjectRecord.setObject(imageAsset, forKey: "photo")
        }
        
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.save(picturedObjectRecord) { (record, error) -> Void in
            if (error != nil){
                print("Error when saving to CK private database: \(String(describing: error?.localizedDescription))")
            }
            else {
                print("CK Save Success")
            }
        }
        
        if (photoObjectArray[0].date == picturedObject.date){
            self.firstObjectTimestampIDforCoreData = String(timestampParts[0])
        }
    }

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
    
    //MARK: 4. Creating Core Data record
    func saveRecordIDtoCoreDataForPhotoCollection(){
        //saving cloudkit id for use in main screen
        //using oldest record as the photo identifier for the collection (folder photo essentially)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //getting CKRecordID context from core data
        let entity = NSEntityDescription.entity(forEntityName: "CloudKitRecord", in: managedContext)!
        //setting value of passed string to CKRecordID.id in core data
        let valueToStore = NSManagedObject(entity: entity, insertInto: managedContext)
        valueToStore.setValue(self.firstObjectTimestampIDforCoreData, forKey: "id")
        
        do {
          try managedContext.save()
            ckRecordIDs.append(valueToStore)
            print("Core data object saved. name-uid")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveCollectionNameToUID_CoreData(){
        //core data: set uid to newCollectionName
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //getting CKRecordID context from core data
        let entity = NSEntityDescription.entity(forEntityName: "CollectionNameUID", in: managedContext)!
        //setting value of passed string to CKRecordID.id in core data
        let valueToStore = NSManagedObject(entity: entity, insertInto: managedContext)
        valueToStore.setValue(self.UID, forKey: "uid")
        valueToStore.setValue(self.newCollectionName, forKey: "name")
        do {
          try managedContext.save()
            collectionName_UIDs.append(valueToStore)
            print("Core data object saved. name-uid")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Error Handling
    
    @objc func uploadButtonPressed() throws {
        do {
            try pageCompletionCheck()
            print("success!")
            print("string id: \(self.newCollectionName)")
        }
        catch pageCompletionError.invalidNameLength {
            print("error length: \(self.newCollectionName.count) ")
            showSimpleAlertWithTitle("Group Name Error", message: "Proposed group names must be between 6 and 36 characters.", viewController: self)
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
    
    func pageCompletionCheck() throws {
        
        //character count between 6-24 chars
        guard newCollectionName.count <= 36 && newCollectionName.count >= 6 else {
            throw pageCompletionError.invalidNameLength
        }
        
        //user must upload images
        guard !photoObjectArray.isEmpty else {
            throw pageCompletionError.invalidPicture
        }
        
        //start upload
        self.preparePhotoAsURL()
        self.saveCollectionNameToUID_CoreData()
        self.saveRecordIDtoCoreDataForPhotoCollection()

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
