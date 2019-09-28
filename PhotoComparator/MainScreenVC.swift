//
//  MainScreenVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/19/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

/*
 
 Store (either whole CKRecord or just CKRecord.ID) assets to quickly populate main screen
 
 upload different kinds of pictures for different folder types
 
 grab all photos of same type, display in chronological order according to date
 
 */

class MainScreenVC: CollectionViewController {

    var photoArray: Array<MainScreenModel> = []
    var ckRecordIDs: [NSManagedObject] = []
    var photoNameRecords: [NSManagedObject] = []
    var photoNameDictionary:[String:String] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Photo Comparator"
        //self.collectionView.backgroundColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)
        self.collectionView.register(MainScreenCell.self, forCellWithReuseIdentifier: "MainScreenCell")
        
        importPhotoButton()

    
    }
    
    //MARK: Retrieving Core Data Info
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        getImageReferenceForFolderFromCoreData()

    }
    
    func getImageReferenceForFolderFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CloudKitRecord")
        do {
            print("Core Data objects obtained: CKRecord References")
            ckRecordIDs = try managedContext.fetch(fetchRequest)

            self.getTitleInfoForFoldersFromCoreData()
            
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    func getTitleInfoForFoldersFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CollectionNameUID")
        do {
            print("Core Data objects obtained: Title info")
            photoNameRecords = try managedContext.fetch(fetchRequest)
            setDictionaryForRecordNames(photoNameRecords)
            self.fetchRecordFromCloud(ckRecordIDs)
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    func setDictionaryForRecordNames(_ CKRecordIdentifiers: [NSManagedObject]){
        for records in photoNameRecords {
            guard let collectionName = records.value(forKey: "name") as? String else {return}
            guard let collectionUID = records.value(forKey: "uid") as? String else {return}
            photoNameDictionary[collectionUID] = collectionName
        }
        
    }
    
    //MARK: Fetch Data From CloudKit
    
    func fetchRecordFromCloud(_ CKRecordIdentifiers: [NSManagedObject]){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        
        for records in CKRecordIdentifiers {
            guard let recordName = records.value(forKey: "id") as? String else {return}
            let ckRecordID = CKRecord.ID(recordName: recordName)
            privateDatabase.fetch(withRecordID: ckRecordID) { (result, error) -> Void in
                if (error != nil){
                    print("error when fetching from database: \(String(describing: error?.localizedDescription))")
                }
                else {
                    guard let record = result else {return}
                    let imageAsset: CKAsset = record.value(forKey: "photo") as! CKAsset
                    let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                    let id = record.value(forKey: "id") as? String
                    guard let collectionName = self.photoNameDictionary[id!] else {return}
                    self.photoArray.append(MainScreenModel(name: "\(collectionName)", image: image!, nameIdentifier: id!))
                }
                OperationQueue.main.addOperation { () -> Void in
                    self.setFetchedDataToCells()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Cell Setup
    
    func setFetchedDataToCells(){
        
        let grid = Grid(columns: 2, margin: UIEdgeInsets(horizontal: 0, vertical: 25), padding: .zero)
        let items = photoArray.map { [weak self] photoArray in
            MainScreenViewModel(photoArray)
                .onSelect { [weak self] viewModel in
                    print("id: \(viewModel.model.nameIdentifier)")
            }
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    //MARK: Import Button Setup
    
    func importPhotoButton(){
        let addButton = UIBarButtonItem(title: ionicon.Plus.rawValue, style: .plain, target: self, action: #selector(addPhotoAction))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        addButton.tintColor = self.view.tintColor
        addButton.setTitleTextAttributes(attributes, for: .normal)
        addButton.setTitleTextAttributes(attributes, for: .highlighted)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addPhotoAction(){
        self.navigationController?.pushViewController(PhotoImportVC(), animated: true)
    }
    
    //MARK: Development Functions
    
    func getALLMainPageFolders(){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PicturedObject", predicate: predicate)

        privateDatabase.perform(query, inZoneWith: nil) { (result, error) -> Void in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                for record in result! {
                        let imageAsset: CKAsset = record.value(forKey: "photo") as! CKAsset
                        let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                    let id = record.recordID.recordName
                    self.photoArray.append(MainScreenModel(name: " ", image: image!, nameIdentifier: id))
                    }
                }
                OperationQueue.main.addOperation { () -> Void in
                    self.setFetchedDataToCells()
                    self.collectionView.reloadData()
                }
            }
        }
    
        func foo(_ f: [NSManagedObject]){
    //        let recordsToAdd = ["591314508-3","591318838-0)","591312320","591313280-3"]
    //
    //        for record in recordsToAdd {
    //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    //        let managedContext = appDelegate.persistentContainer.viewContext
    //        //getting CKRecordID context from core data
    //        let entity = NSEntityDescription.entity(forEntityName: "CloudKitRecord", in: managedContext)!
    //        //setting value of passed string to CKRecordID.id in core data
    //            let valueToStore = NSManagedObject(entity: entity, insertInto: managedContext)
    //            valueToStore.setValue(record, forKey: "id")
    //
    //            do {
    //              try managedContext.save()
    //                ckRecordIDs.append(valueToStore)
    //                print("Core data object saved: \(record)")
    //            } catch let error as NSError {
    //              print("Could not save. \(error), \(error.userInfo)")
    //
    //            }}

            for record in f {
                if let name = record.value(forKey: "id") as? String {
                    print("name: \(name)")
                }
            }
            
    //        for items in f {
    //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    //        let managedContext = appDelegate.persistentContainer.viewContext
    //        managedContext.delete(items)
    //
    //        do {
    //            try managedContext.save()
    //        } catch _ {
    //            }}
        }
    
    
}





