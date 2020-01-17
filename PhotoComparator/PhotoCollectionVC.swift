//
//  PhotoCollectionVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class PhotoCollectionVC: CollectionViewController {
    
    //MARK: Variable Declaration
    var coreDataContext: NSManagedObjectContext! = nil
    var collectionNameUID: String = ""
    var updatedCollectionName: String?
    var collectionFolder_CKRecord: CKRecord?
    
    var photoModel: PhotoCollectionObject!
    var photoArray: Array<PhotoCollectionObject> = []
    var photoArray_ObjectsToCompare: Array<PhotoCollectionObject> = []
    var photoArray_ObjectsToMerge: Array<PhotoCollectionObject> = []
    

    var photoKeyToQuery: String = ""
    var viewPhoto = ViewPhoto_View()
    var compareButton = CompareButton()
    var coreDataFunctions = CoreDataFunctions()
    var cloudkitOperations = CloudKitFunctions()

    enum vcMode {
        case observe
        case compare
        case delete
        case merge
    }
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.collectionView.backgroundColor = UIColor.dynamicBackgroundColor
        } else {
            self.collectionView.backgroundColor = UIColor.white
        }

        self.photoKeyToQuery = photoModel.id
        
        self.navigationItem.leftBarButtonItem = setBackButton()
        self.navigationItem.rightBarButtonItem = collectionOptionsButton()
        setupCompareButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (getUserDefaultStorageType() == "Cloud"){
            fetchRecordFromCloud()
        }
        else {
            fetchCollectionFromCoreData()
        }
        
        //sets all views back to normal
        self.cancelCompareMode()
    }
    
    //MARK: Cell Setup
    
    func setupCells(mode: vcMode){
        var header = HeaderViewModel(.init(title: "\(photoModel.name)"))

        if (self.updatedCollectionName != nil){
            header = HeaderViewModel(.init(title: "\(self.updatedCollectionName!)"))
        }
        
        let items = photoArray.map { [weak self] photoArray in
            PhotoCollectionViewModel(photoArray)
                .onSelect{ [weak self]  viewModel in
                    switch mode {
                    case .observe:
                        let photoView = ViewPhotoModeVC(nibName: nil, bundle: nil)
                        photoView.photoArray = self!.photoArray
                        photoView.index = viewModel.indexPath.row
                        photoView.modalPresentationStyle = .overFullScreen
                        self?.present(photoView, animated: false, completion: nil)
                    case .compare:
                        viewModel.model.hideBlurView.toggle()
                        if (viewModel.model.hideBlurView){
                            //image is selected
                            self?.photoArray_ObjectsToCompare.append(viewModel.model)
                        }
                        else {
                            //image is unselected
                            self?.photoArray_ObjectsToCompare.removeAll(where: {$0.ckrecordID == viewModel.model.ckrecordID})
                        }
                        self!.collectionView.reloadData()
                        break
                    case .delete:
                        //MARK: Delete
                        let deletionNotice = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this photo? This cannot be undone.", preferredStyle: .alert)
                        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                            alert -> Void in
                            
                            if (self!.getUserDefaultStorageType() == "Cloud"){
                                print("delete: \(viewModel.model.ckrecordID.recordName)")
                                if !(self?.photoModel.ckrecordID == viewModel.model.ckrecordID){
                                    self?.cloudkitOperations.deleteRecord(photo: viewModel.model)
                                    self?.collectionView.reloadData()
                                    self?.cancelPhotoDeletion()
                                    }
                                else {
                                    print("cant delete folder picture CK")
                                }
                            }
                            else {
                                //core data deletion
                                if !(self?.photoModel.id == viewModel.model.id){
                                    self?.coreDataFunctions.deleteRecordWithID(id: viewModel.model.id)
                                    self?.collectionView.reloadData()
                                    self?.cancelPhotoDeletion()
                                }
                                else {
                                    print("cant delete folder picture CD")
                                }
                            }
    
                        })
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        deletionNotice.addAction(deleteAction)
                        deletionNotice.addAction(cancelAction)
                        self!.present(deletionNotice, animated: true, completion: nil)
                        break
                    case .merge:
                        //view subset of photos
                        viewModel.model.hideBlurView.toggle()
                        if (viewModel.model.hideBlurView){
                            //image is selected
                            self?.photoArray_ObjectsToMerge.append(viewModel.model)
                        }
                        else {
                            //image is unselected
                            self?.photoArray_ObjectsToMerge.removeAll(where: {$0.ckrecordID == viewModel.model.ckrecordID})
                        }
                        self!.collectionView.reloadData()
                    break
                    }
            }
        }
        let grid = Grid(columns: 1, margin: UIEdgeInsets(horizontal: 0, vertical: 35), padding: .zero)
        let photoSection = Section(grid: grid, header: header, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    

    //MARK: CloudKit Data Fetch
    
    func fetchRecordFromCloud(){
        
       let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
       let privateDatabase = container.privateCloudDatabase
        //let predicate = NSPredicate(value: true) //gets all photos
        let predicate = NSPredicate(format: "id == %@", self.photoKeyToQuery)
        
       let query = CKQuery(recordType: "PicturedObject", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
           if error != nil {
            print("Cloudkit Download PhotoCollectionVC error: \(String(error!.localizedDescription))")
           }
           else {
               for result in results! {
                guard let date = result.value(forKey: "date") as? NSDate else {return}
                let recordID = result.recordID
                let imageAsset: CKAsset = result.value(forKey: "photo") as! CKAsset
                let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                self.photoArray.append(PhotoCollectionObject(date: date, photo: image!, id: self.photoModel.id, name: self.photoModel.name, ckrecordID: recordID, hideBlurView: true))
                
                if (date == self.photoModel.date){
                    //setting valid value of ckRecord.ID for photoModel
                    self.photoModel.ckrecordID = recordID
                }
               }
            
            OperationQueue.main.addOperation({ () -> Void in
                self.setupCells(mode: .observe)
                self.collectionView.reloadData()
                })
           }
       }
    }
    
    //MARK: CoreData Fetch
    
    func fetchCollectionFromCoreData(){
        
        coreDataFunctions.loadCollectionWithNameUID(nameUID: collectionNameUID, collectionName: photoModel.name)
        self.photoArray = coreDataFunctions.collectionPhotoArray
        OperationQueue.main.addOperation({ () -> Void in
            self.setupCells(mode: .observe)
            self.collectionView.reloadData()
            })
    }
    
    //MARK: Compare Setup
    func setupCompareButton(){
        self.view.addSubview(compareButton)
        self.compareButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.compareButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        self.compareButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
        self.compareButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.compareButton.addTarget(self, action: #selector(cropAndMergePhotos), for: .touchUpInside)
        self.view.bringSubviewToFront(compareButton)
    }

    
    func comparePhotos(){
        photoArray_ObjectsToCompare.removeAll()
        self.compareButton.isHidden = true

        for index in 0..<photoArray.count {
            photoArray[index].hideBlurView = false
        }
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelCompareMode))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let compareButton = UIBarButtonItem(title: "Compare", style: .plain, target: self, action: #selector(compareSelectedPhotos))
        self.navigationItem.rightBarButtonItem = compareButton
        
        self.setupCells(mode: .compare)
    }
    
    @objc func compareSelectedPhotos(){
        if (photoArray_ObjectsToCompare.count > 1){
            let photoView = ViewPhotoModeVC(nibName: nil, bundle: nil)
            photoView.photoArray = self.photoArray_ObjectsToCompare
            photoView.index = 0
            photoView.modalPresentationStyle = .overFullScreen
            self.present(photoView, animated: false, completion: nil)
        }
        else {
            showSimpleAlertWithTitle("Error", message: "You must select 2 or more pictures in order to compare!", viewController: self)
        }
    }
    
    
    @objc func cancelCompareMode(){
        self.compareButton.isHidden = false
        
        for index in 0..<photoArray.count {
            photoArray[index].hideBlurView = true
        }
        
        self.navigationItem.rightBarButtonItem = collectionOptionsButton()
        self.navigationItem.leftBarButtonItem = setBackButton()
        self.setupCells(mode: .observe)
    }
    
    
    //MARK: Navigation Bar buttons
    
    func setBackButton() -> UIBarButtonItem {
        let backButton = UIBarButtonItem(title: ionicon.ChevronLeft.rawValue + " Back", style: .plain, target: self, action: #selector(dismissController))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(18)] as Dictionary
        backButton.tintColor = self.view.tintColor
        backButton.setTitleTextAttributes(attributes, for: .normal)
        backButton.setTitleTextAttributes(attributes, for: .highlighted)
        return backButton
    }
    
    @objc func dismissController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionOptionsButton() -> UIBarButtonItem{
        let deleteButton = UIBarButtonItem(title: ionicon.iOSMore.rawValue, style: .plain, target: self, action: #selector(showMoreOptions))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        deleteButton.tintColor = self.view.tintColor
        deleteButton.setTitleTextAttributes(attributes, for: .normal)
        deleteButton.setTitleTextAttributes(attributes, for: .highlighted)
        return deleteButton
    }
    
    //MARK: Show options menu
    @objc func showMoreOptions(){
        let moreOptionsAlert = UIAlertController(title: "Collection Options", message: "", preferredStyle: .actionSheet)
        
        let importNewPhotosOption = UIAlertAction(title: "Import More Photos", style: .default) { handler in
            self.importNewPhotos()
        }
        let changeCollectionNameOption = UIAlertAction(title: "Change Collection Name", style: .default) { handler in
            self.changeCollectionFolderNameAction()
        }
        let cropAndMergePhotosOption = UIAlertAction(title: "View Subset of Photos", style: .default) { handler in
            self.comparePhotos()
        }
        let deleteSinglePhotoOption = UIAlertAction(title: "Delete a Photo", style: .destructive) { handler in
            self.deleteSinglePhotoAction()
        }
        let deleteCollectionOption = UIAlertAction(title: "Delete Collection", style: .destructive) { handler in
            self.deleteCollectionAction()
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        moreOptionsAlert.addAction(importNewPhotosOption)
        moreOptionsAlert.addAction(changeCollectionNameOption)
        moreOptionsAlert.addAction(cropAndMergePhotosOption)
        moreOptionsAlert.addAction(deleteSinglePhotoOption)
        moreOptionsAlert.addAction(deleteCollectionOption)
        moreOptionsAlert.addAction(cancelOption)
        
        self.present(moreOptionsAlert, animated: true, completion: nil)
    }
    
    //MARK: Import new photo
    func importNewPhotos(){
        let photoImportVC = PhotoImportVC()
        photoImportVC.coreDataContext = self.coreDataContext
        photoImportVC.coreDataFunctions = self.coreDataFunctions
        photoImportVC.cloudkitOperations = self.cloudkitOperations
        photoImportVC.UID = self.collectionNameUID as NSString
        photoImportVC.photoUploadOperations(operation: .existingCollection)
        photoImportVC.title = "\(self.photoModel.name)"
        self.navigationController?.pushViewController(photoImportVC, animated: true)
    }
    
    //MARK: Update collection name
    func changeCollectionFolderNameAction(){
        let changeNameNotice = UIAlertController(title: "Change Collection Name", message: "Fill in the text field with the updated collection name.", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Update", style: .default, handler: {
            alert -> Void in
            let textField = changeNameNotice.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            textField.placeholder = self.photoModel.name
            self.updatedCollectionName = textField.text!
            self.checkCollectionName()
        })
        changeNameNotice.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = self.photoModel.name }
        changeNameNotice.addAction(getInput)
        changeNameNotice.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(changeNameNotice, animated: true, completion: nil)
        
    }
    
    enum pageCompletionError: Error {
        case invalidNameLength
    }
    
    func checkCollectionName(){
        do {
            try self.updateCollectionName()
        }
        catch pageCompletionError.invalidNameLength {
             showSimpleAlertWithTitle("Error", message: "The colleciton name must be between 6 and 24 characters.", viewController: self)
        }
        catch {
            showSimpleAlertWithTitle("Error", message: "Collection name could not be updated at this time. Please try again later.", viewController: self)
        }
    }
    
    func updateCollectionName() throws {
        guard self.updatedCollectionName!.count <= 36 && self.updatedCollectionName!.count >= 6 else {
            throw pageCompletionError.invalidNameLength
        }
        
        if(getUserDefaultStorageType() == "Cloud"){
            //ck name update
            self.setupCells(mode: .observe)
            if let record = self.collectionFolder_CKRecord {
                self.cloudkitOperations.updateFolderName(newFolderName: self.updatedCollectionName!, folderToUpdate: record)
            }
        }
        else {
            self.setupCells(mode: .observe)
            self.coreDataFunctions.updateCollectionName(collectionName: self.updatedCollectionName!, nameUID: self.collectionNameUID)
        }
    }
    
    
    //MARK: Delete collection action
    
    func deleteCollectionAction(){
        
        let deletionNotice = UIAlertController(title: "Delete Collection", message: "Are you sure you would like to delete this entire collection of photos? This cannot be undone.", preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            alert -> Void in
            
            if (self.getUserDefaultStorageType() == "Cloud"){
                self.cloudkitOperations.deleteCollection(photoArray: self.photoArray)
            }
            else {
                self.coreDataFunctions.deleteCollectionWithUID(uid: self.collectionNameUID)
                self.coreDataFunctions.deleteCollectionWithUID(uid: self.collectionNameUID)
            }
            self.navigationController?.popViewController(animated: true)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        deletionNotice.addAction(cancelAction)
        deletionNotice.addAction(continueAction)
        self.present(deletionNotice, animated: true, completion: nil)

    }
    
    //MARK: Delete a photo action
    
    func deleteSinglePhotoAction(){
        self.view.layer.masksToBounds = true
        self.view.layer.borderColor = UIColor.red.cgColor
        self.view.layer.borderWidth = 5
        compareButton.isHidden = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelPhotoDeletion))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = nil
        setupCells(mode: .delete)
    }
    
    @objc func cancelPhotoDeletion(){
        self.view.layer.borderColor = UIColor.clear.cgColor
        self.view.layer.borderWidth = 0
        self.navigationItem.leftBarButtonItem = setBackButton()
        self.navigationItem.rightBarButtonItem = collectionOptionsButton()
        self.compareButton.isHidden = false
    }
    
    //MARK: Crop and Merge Photos
    //https://appsbydeb.wordpress.com/2016/01/07/ios-swift-simple-image-cropping-app/
    
    @objc func cropAndMergePhotos(){
//        let step1DirectionsNotice = UIAlertController(title: "Compare and Merge Two Photos", message: "Begin by selecting two photos you would like to compare, side-by-side. This will not change the original chosen photos. After you have finished making your selection, press the Next button.", preferredStyle: .alert)
//        let okButton = UIAlertAction(title: "Continue", style: .default) { handler in
//            self.setupCropAndMergeLayout()
//        }
//        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        step1DirectionsNotice.addAction(okButton)
//        step1DirectionsNotice.addAction(cancelButton)
//        self.present(step1DirectionsNotice, animated: true, completion: nil)
        
        self.setupCropAndMergeLayout()
    }
    
    func setupCropAndMergeLayout(){
        compareButton.isHidden = true
        photoArray_ObjectsToMerge.removeAll()
        for index in 0..<photoArray.count {
            photoArray[index].hideBlurView = false
        }
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelCompareMode))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let compareButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(cropAndMergeStep2))
        self.navigationItem.rightBarButtonItem = compareButton
        
        
        self.setupCells(mode: .merge)
    }
    
    @objc func cropAndMergeStep2(){
        if (photoArray_ObjectsToMerge.count == 2){
            let cropMergeVC = Crop_MergeVC()
            cropMergeVC.photoArray_ObjectsToMerge = self.photoArray_ObjectsToMerge
            cropMergeVC.index = 0
            cropMergeVC.cloudkitOperations = cloudkitOperations
            self.navigationController?.pushViewController(cropMergeVC, animated: true)
        }
        else {
            showSimpleAlertWithTitle("Error", message: "You must only select two photos to crop and merge.", viewController: self)
        }
    }
    
    //MARK: UserDefault StorageType
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
}
