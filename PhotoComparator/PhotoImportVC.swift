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

class PhotoImportVC: CollectionViewController {

    let imagePicker = UIImagePickerController()
    var photoObjectArray:[PicturedObject] = []
    let photoSize = CGSize(width: 2000, height: 1500)
    
    var stringIdentifier: String = ""
    var imageURL: URL!
    let header = InputTitleHeaderViewModel(.init(inputtedTitle: ""))

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
        
        selectPhotosFromLibrary()
    }

    //MARK: Selecting photos and populating collection view
    
    func selectPhotosFromLibrary(){
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 10
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in },
            deselect: { (asset: PHAsset) -> Void in },
            cancel: { (assets: [PHAsset]) -> Void in },
            finish: { (assets: [PHAsset]) -> Void in
                
                for (index, pic) in assets.enumerated() {
                    guard let creationDate = pic.creationDate else {return}
                    guard let image = self.getImageFromPHAsset(pic, size: self.photoSize, deliverMode: .highQualityFormat) else {return}
                    
                    let picturedObject = PicturedObject(
                        name: self.stringIdentifier as NSString,
                        date: creationDate as NSDate,
                        photo: image,
                        id: NSNumber(value: index))
               
                    self.photoObjectArray.append(picturedObject)
                }
                self.setupCells()
        }, completion: nil)
    }

    func setupCells(){
        let grid = Grid(columns: 1, margin: UIEdgeInsets(all: 8), padding: .zero)
        let itemsToDisplay = self.photoObjectArray.map { [weak self] photoObjectArray in
            PhotoImportViewModel(photoObjectArray)
        }
        let photoSection = Section(grid: grid, header: header, footer: nil, items: itemsToDisplay)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()

        //preparePhotoAsURL()
    }
    
    //MARK: Cloudkit object upload
    
    func preparePhotoAsURL(){
        for picturedObject in photoObjectArray {
            
            let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            
            let imageData = picturedObject.photo.jpegData(compressionQuality: 0.8)
            let path = documentsDirectoryPath.appendingPathComponent(picturedObject.name as String)
            imageURL = URL(fileURLWithPath: path)
            do {
                try imageData?.write(to: imageURL as URL)
                saveSaveURL_CK(picturedObject: picturedObject)
            } catch let error as NSError {
                showSimpleAlertWithTitle("Error", message: "An internal error occurred on photo upload. Please try again later.", viewController: self)
                print("photo upload write to URL Failed. Underlying error \(error)")
            }
        }
    }
    
    func saveSaveURL_CK(picturedObject: PicturedObject){
        let timestampAsString = String(format: "%f", Date.timeIntervalSinceReferenceDate)
        //creating uid for CKRecords
        let timestampParts = timestampAsString.components(separatedBy: ".")
        let noteID = CKRecord.ID(recordName: timestampParts[0])
        let picturedObjectRecord = CKRecord(recordType: "PicturedObject", recordID: noteID)
        picturedObjectRecord.setValue(picturedObject.name, forKey: "name")
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
    
    
    //MARK: Error Handling
    
    @objc func uploadButtonPressed() throws {
        do {
            self.stringIdentifier = header.model.inputtedTitle
            try pageCompletionCheck()
            print("success!")
            print("string id: \(self.stringIdentifier)")
        }
        catch pageCompletionError.invalidNameLength {
            print("error length: \(self.stringIdentifier.count) ")
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
        guard stringIdentifier.count <= 36 && stringIdentifier.count >= 6 else {
            throw pageCompletionError.invalidNameLength
        }
        
        //user must upload images
        guard !photoObjectArray.isEmpty else {
            throw pageCompletionError.invalidPicture
        }
        
        //self.preparePhotoAsURL()
    
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
