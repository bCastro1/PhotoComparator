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

class PhotoCollectionVC: CollectionViewController, PhotoComparisonProtocol {
    
    var photoComparisonIndex: Int = 0
    var shouldComparePhotos: Bool = false
    
    //MARK: Variable Declaration
    var collectionNameUID: String = ""
    var updatedCollectionName: String?
    var collectionFolder_CKRecord: CKRecord?
    
    var photoModel: PhotoCollectionObject!
    var photoArray: Array<PhotoCollectionObject> = []
    var photoArray_ObjectsToCompare: Array<PhotoCollectionObject> = []
    var photoArray_ObjectsToMerge: Array<PhotoCollectionObject> = []
    

    var photoKeyToQuery: String = ""
    var viewPhoto = ViewPhoto_View()

    enum vcMode {
        case observe
        case compare
        case delete
        case merge
    }
    
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
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .dynamicBackground()

        self.photoKeyToQuery = photoModel.id
        
        self.navigationItem.leftBarButtonItem = setBackButton()
        self.navigationItem.rightBarButtonItem = collectionOptionsButton()
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        if (shouldComparePhotos){
            shouldComparePhotos = false
            let cameraVC = CameraCaptureVC(
                coreDataFunctions: self.coreDataFunctions!,
                cloudKitOperations: self.cloudkitOperations!,
                comparisonPhoto: self.photoArray[photoComparisonIndex].photo, AlbumUID: collectionNameUID as NSString, AlbumName: self.photoArray[photoComparisonIndex].name)
            cameraVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cameraVC, animated: true)
        }
        self.navigationController?.navigationBar.isHidden = false
        albumDataFetch()
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
                        let photoView = ViewPhotoModeVC(coreDataFunctions: (self?.coreDataFunctions)!, cloudKitOperations: (self?.cloudkitOperations)!, photoCollectionVC: self!)
                        photoView.photoArray = self!.photoArray
                        photoView.index = viewModel.indexPath.row
                        photoView.modalPresentationStyle = .fullScreen
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
                                    self?.cloudkitOperations!.deleteRecord(photo: viewModel.model)
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
                                    self?.coreDataFunctions?.deleteRecordWithID(id: viewModel.model.id)
                                    self?.collectionView.reloadData()
                                    self?.cancelPhotoDeletion()
                                }
                                else {
                                    print("cant delete folder picture CD")
                                }
                            }
                            self?.albumDataFetch()
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
    
    func albumDataFetch(){
        if (getUserDefaultStorageType() == "Cloud"){
            fetchRecordFromCloud()
        }
        else {
            fetchCollectionFromCoreData()
        }
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
        
        coreDataFunctions?.loadCollectionWithNameUID(nameUID: collectionNameUID, collectionName: photoModel.name)
        guard let unwrappedPhotoArray = self.coreDataFunctions?.collectionPhotoArray else {return}
        self.photoArray = unwrappedPhotoArray
        
        OperationQueue.main.addOperation({ () -> Void in
            self.setupCells(mode: .observe)
            self.collectionView.reloadData()
            })
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
        let moreOptionsAlert = UIAlertController(title: "Album Options", message: "", preferredStyle: .actionSheet)
        
        let importNewPhotosOption = UIAlertAction(title: "Import More Photos", style: .default) { handler in
            self.importNewPhotos()
        }
        let changeCollectionNameOption = UIAlertAction(title: "Change Collection Name", style: .default) { handler in
            self.changeCollectionFolderNameAction()
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
        moreOptionsAlert.addAction(deleteSinglePhotoOption)
        moreOptionsAlert.addAction(deleteCollectionOption)
        moreOptionsAlert.addAction(cancelOption)
        
        self.present(moreOptionsAlert, animated: true, completion: nil)
    }
    
    //MARK: Import new photo
    func importNewPhotos(){
        let photoImportVC = PhotoImportVC(coreDataFunctions: coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
        photoImportVC.newCollectionName = self.photoModel.name
        photoImportVC.title = "\(self.photoModel.name)"
        photoImportVC.photoUploadOperations(operation: .existingCollection, uid: self.collectionNameUID as NSString)
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
            showSimpleAlertWithTitle("Error", message: "Album name could not be updated at this time. Please try again later.", viewController: self)
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
                self.cloudkitOperations!.updateFolderName(newFolderName: self.updatedCollectionName!, folderToUpdate: record)
            }
        }
        else {
            self.setupCells(mode: .observe)
            self.coreDataFunctions?.updateCollectionName(collectionName: self.updatedCollectionName!, nameUID: self.collectionNameUID)
        }
    }
    
    //MARK: Delete collection action
    
    func deleteCollectionAction(){
        
        let deletionNotice = UIAlertController(title: "Delete Collection", message: "Are you sure you would like to delete this entire collection of photos? This cannot be undone.", preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            alert -> Void in
            
            if (self.getUserDefaultStorageType() == "Cloud"){
                self.cloudkitOperations!.deleteCollection(photoArray: self.photoArray)
            }
            else {
                self.coreDataFunctions?.deleteCollectionWithUID(uid: self.collectionNameUID)
                self.coreDataFunctions?.deleteCollectionWithUID(uid: self.collectionNameUID)
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
        setupCells(mode: .observe)
    }
    
    
    //MARK: UserDefault StorageType
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
}
