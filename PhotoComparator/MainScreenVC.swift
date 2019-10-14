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


class MainScreenVC: CollectionViewController {
    
    var coreDataContext: NSManagedObjectContext! = nil
    
    var photoArray: Array<MainScreenModel> = []
    var coreDataFunctions = CoreDataFunctions()
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photo Comparator"
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)
        self.collectionView.register(MainScreenCell.self, forCellWithReuseIdentifier: "MainScreenCell")
        
        coreDataFunctions.setAssets(coreDataContext)
        fetchRecordFromCloud()
        
        importPhotoButton()
        refreshButton()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        //self.getALLMainPageFolders()

    }
    
    //MARK: Fetch Data From CloudKit
    
    func fetchRecordFromCloud(){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(format: "NOT (recordID IN %@)", coreDataFunctions.ckRecordID_RecordIDs)
       let query = CKQuery(recordType: "PicturedObject", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
           if error != nil {
            print("Cloudkit Download MainScreenVC error: \(String(error!.localizedDescription))")
           }
           else {
               for result in results! {
                    guard let id = result.value(forKey: "id") as? String else {return}
                    if !(self.photoArray.contains(where: {$0.id == id})){
                        //unique records only
                        let imageAsset: CKAsset = result.value(forKey: "photo") as! CKAsset
                        let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                        let date = result.value(forKey: "date") as? NSDate
                        if let collectionName = self.coreDataFunctions.photoNameDictionary[id] {
                            self.photoArray.append(MainScreenModel(name: "\(collectionName)", image: image!, id: id, date: date!))
                        }
                        else {
                            self.photoArray.append(MainScreenModel(name: "unknown name", image: image!, id: id, date: date!))
                        }
                    }
            }
    
            OperationQueue.main.addOperation({ () -> Void in
                self.setFetchedDataToCells()
                self.collectionView.reloadData()
               })
           }
       }
    }
    
    //MARK: Cell Setup
    
    func setFetchedDataToCells(){
        
        let grid = Grid(columns: 2, margin: UIEdgeInsets(horizontal: 0, vertical: 25), padding: .zero)
        let items = photoArray.map { [weak self] photoArray in
            MainScreenViewModel(photoArray)
                .onSelect { [weak self] viewModel in
                    let collectionViewController = PhotoCollectionVC(nibName: nil, bundle: nil)
                    let date = viewModel.model.date
                    let photo = viewModel.model.image
                    let id = viewModel.model.id
                    let name = viewModel.model.name
                    //MARK: Present Collection VC
                    collectionViewController.photoModel = PhotoCollectionObject(date: date, photo: photo, id: id, name: name, ckrecordID: CKRecord.ID(recordName: "foo"), hideBlurView: true)
                    collectionViewController.coreDataContext = self?.coreDataContext
                    collectionViewController.coreDataFunctions = self!.coreDataFunctions
                    self?.show(collectionViewController, sender: nil)
            }
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    //MARK: Nav Button Setup
    
    func importPhotoButton(){
        let addButton = UIBarButtonItem(title: ionicon.Plus.rawValue, style: .plain, target: self, action: #selector(addPhotoAction))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        addButton.tintColor = self.view.tintColor
        addButton.setTitleTextAttributes(attributes, for: .normal)
        addButton.setTitleTextAttributes(attributes, for: .highlighted)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addPhotoAction(){
        let photoImportVC = PhotoImportVC()
        photoImportVC.coreDataContext = self.coreDataContext
        photoImportVC.coreDataFunctions = self.coreDataFunctions
        photoImportVC.photoUploadOperations(operation: .newCollection)
        photoImportVC.title = "New Collection"
        self.navigationController?.pushViewController(photoImportVC, animated: true)
    }
    
    func refreshButton(){
        let refreshButton = UIBarButtonItem(title: ionicon.Refresh.rawValue, style: .plain, target: self, action: #selector(refreshButtonAction))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        refreshButton.tintColor = self.view.tintColor
        refreshButton.setTitleTextAttributes(attributes, for: .normal)
        refreshButton.setTitleTextAttributes(attributes, for: .highlighted)
        self.navigationItem.leftBarButtonItem = refreshButton
    }
    
    @objc func refreshButtonAction(){
        coreDataFunctions.setAssets(coreDataContext)
        photoArray.removeAll()
        fetchRecordFromCloud()
    }
    
    
    //MARK: Development Functions
    
    func getALLMainPageFolders(){
//        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
//        let privateDatabase = container.privateCloudDatabase
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "PicturedObject", predicate: predicate)
//        privateDatabase.perform(query, inZoneWith: nil) { (result, error) -> Void in
//            if error != nil {
//                print(error?.localizedDescription as Any)
//            }
//            else {
//                for record in result! {
//                    print("id: \(record.recordID)")
//                        let imageAsset: CKAsset = record.value(forKey: "photo") as! CKAsset
//                        let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
//                    let id = record.recordID.recordName
//                    self.photoArray.append(MainScreenModel(name: " ", image: image!, id: id, date: NSDate()))
//                    }
//                }
//                OperationQueue.main.addOperation { () -> Void in
//                    self.setFetchedDataToCells()
//                    self.collectionView.reloadData()
//                }
//            }
//        }
    }
        func foo(_ f: [NSManagedObject]){
//            let recordsToAdd = ["591314508-3","591318838-0)","591312320","591313280-3"]
//
//            for record in recordsToAdd {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            let managedContext = appDelegate.persistentContainer.viewContext
//            //getting CKRecordID context from core data
//            let entity = NSEntityDescription.entity(forEntityName: "CloudKitRecord", in: managedContext)!
//            //setting value of passed string to CKRecordID.id in core data
//                let valueToStore = NSManagedObject(entity: entity, insertInto: managedContext)
//                valueToStore.setValue(record, forKey: "id")
//
//                do {
//                  try managedContext.save()
//                    ckRecordIDs.append(valueToStore)
//                    print("Core data object saved: \(record)")
//                } catch let error as NSError {
//                  print("Could not save. \(error), \(error.userInfo)")
//
//                }}

            for record in f {
                if let name = record.value(forKey: "id") as? String {
                    print("name: \(name)")
                }
            }
            
//            let nameRecordsToAdd:[String] = ["Echeveria Agaviodes","Echeveria Cubic Frost", "Bunny Ear Cactus", "Assorted Blue Pot"]
//            let nameIDsToAdd:[String] = ["A425AB05-F2D0-480B-B781-4ED8D7EEDCE0"
//            ,"4DCE67D8-052C-4166-973E-2162FFE3C33B"
//            ,"7D5932DA-EFB6-48F6-98B9-6B5A1902842D"
//            ,"BB42AC7A-BC18-42DE-B21F-657EB060922F"]
//            for (index,record) in nameRecordsToAdd.enumerated() {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            let managedContext = appDelegate.persistentContainer.viewContext
//            //getting CKRecordID context from core data
//            let entity = NSEntityDescription.entity(forEntityName: "CollectionNameUID", in: managedContext)!
//            //setting value of passed string to CKRecordID.id in core data
//                let valueToStore = NSManagedObject(entity: entity, insertInto: managedContext)
//                valueToStore.setValue(record, forKey: "name")
//                valueToStore.setValue(nameIDsToAdd[index], forKey: "uid")
//                do {
//                  try managedContext.save()
//                    photoNameRecords.append(valueToStore)
//                    print("Core data object saved: \(record)")
//                } catch let error as NSError {
//                  print("Could not save. \(error), \(error.userInfo)")
//
//                }}
        
            /*purge all*/
//            for items in f {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            let managedContext = appDelegate.persistentContainer.viewContext
//            managedContext.delete(items)
//
//            do {
//                try managedContext.save()
//            } catch _ {
//                }}
        }
    
    
}

//590980952





