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
    
    var photoModel: PhotoCollectionObject!
    var photoArray: Array<PhotoCollectionObject> = []
    var photoArray_ObjectsToCompare: Array<PhotoCollectionObject> = []

    var photoKeyToQuery: String = ""
    var viewPhoto = ViewPhoto_View()
    var compareButton = CompareButton()
    var coreDataFunctions = CoreDataFunctions()
    
    enum vcMode {
        case observe
        case compare
    }
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)
        self.photoKeyToQuery = photoModel.id
        
        fetchRecordFromCloud()
        self.navigationItem.leftBarButtonItem = setBackButton()
        self.navigationItem.rightBarButtonItem = collectionOptionsButton()
        setupCompareButton()
    }
    
    
    
    //MARK: Cell Setup
    
    func setupCells(mode: vcMode){
        
        let header = HeaderViewModel(.init(title: "\(photoModel.name)"))
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
    
    //MARK: Compare Setup
    func setupCompareButton(){
        self.view.addSubview(compareButton)
        self.compareButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.compareButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        self.compareButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
        self.compareButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.compareButton.addTarget(self, action: #selector(comparePhotos), for: .touchUpInside)
        self.view.bringSubviewToFront(compareButton)
    }
    
    @objc func comparePhotos(){
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
    
    
    //MARK: Navigation Bar Options
    
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
    
    @objc func showMoreOptions(){
        let moreOptionsAlert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let importNewPhotosOption = UIAlertAction(title: "Import More Photos", style: .default) { handler in
            self.importNewPhotos()
        }
        let deleteCollectionOption = UIAlertAction(title: "Delete Collection", style: .destructive) { handler in
            self.deleteCollectionAction()
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        moreOptionsAlert.addAction(importNewPhotosOption)
        moreOptionsAlert.addAction(deleteCollectionOption)
        moreOptionsAlert.addAction(cancelOption)
        
        self.present(moreOptionsAlert, animated: true, completion: nil)
    }
    
            //MARK: Import new photo
    func importNewPhotos(){
        let photoImportVC = PhotoImportVC()
        photoImportVC.coreDataContext = self.coreDataContext
        photoImportVC.coreDataFunctions = self.coreDataFunctions
        photoImportVC.UID = photoModel.id as NSString
        photoImportVC.photoUploadOperations(operation: .existingCollection)
        photoImportVC.title = "\(self.photoModel.name)"
        self.navigationController?.pushViewController(photoImportVC, animated: true)
    }
    
    func deleteCollectionAction(){
        
        let deletionNotice = UIAlertController(title: "Delete Collection", message: "Are you sure you would like to delete this entire collection of photos? This cannot be undone.", preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            alert -> Void in
            
            let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
            let privateDatabase = container.privateCloudDatabase
            for item in self.photoArray {
                privateDatabase.delete(withRecordID: item.ckrecordID, completionHandler: {recordID, error in
                    NSLog("OK or \(String(describing: error))")
                })
            }
            self.coreDataFunctions.delete_CollectionNameAsset(uid: self.photoModel.id)
            self.coreDataFunctions.delete_CKRecordIDAsset(recordIdentifier: self.photoModel.ckrecordID.recordName)
            self.navigationController?.popViewController(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        deletionNotice.addAction(cancelAction)
        deletionNotice.addAction(continueAction)
        self.present(deletionNotice, animated: true, completion: nil)

    }
    
}
