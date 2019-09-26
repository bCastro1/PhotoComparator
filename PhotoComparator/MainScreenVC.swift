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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Photo Comparator"
        //self.collectionView.backgroundColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "pw_pattern")!)
        self.collectionView.register(MainScreenCell.self, forCellWithReuseIdentifier: "MainScreenCell")
        
        importPhotoButton()

        
        //fetchRecordFromCloud("590980952")
        //saveCKRecordID(ckRecordID: "590980952")
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CloudKitRecord")
        do {
            print("Core Data objects obtained.")
            ckRecordIDs = try managedContext.fetch(fetchRequest)
            self.fetchRecordFromCloud(ckRecordIDs)
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    
    func saveCKRecordID(ckRecordID: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //getting CKRecordID context from core data
        let entity = NSEntityDescription.entity(forEntityName: "CloudKitRecord", in: managedContext)!
        //setting value of passed string to CKRecordID.id in core data
        let recordID = NSManagedObject(entity: entity, insertInto: managedContext)
        recordID.setValue(ckRecordID, forKey: "id")
        
        do {
          try managedContext.save()
            ckRecordIDs.append(recordID)
            print("Core data object saved.")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchRecordFromCloud(_ CKRecordIdentifiers: [NSManagedObject]){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        
        for records in CKRecordIdentifiers {
            guard let recordName = records.value(forKeyPath: "id") as? String else {return}
            let ckRecordID = CKRecord.ID(recordName: recordName)
            privateDatabase.fetch(withRecordID: ckRecordID) { (result, error) -> Void in
                if (error != nil){
                    print("error when fetching from database: \(String(describing: error?.localizedDescription))")
                }
                else {
                    guard let record = result else {return}
                    print("record id?: \(record.recordID)")
                    let imageAsset: CKAsset = record.value(forKey: "photo") as! CKAsset
                    let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                    let name = record.value(forKey: "name") as? String
                    self.photoArray.append(MainScreenModel(name: name!, image: image!))
                }
                OperationQueue.main.addOperation { () -> Void in
                    self.setFetchedDataToCells()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func setFetchedDataToCells(){
        
        let grid = Grid(columns: 2, margin: UIEdgeInsets(horizontal: 0, vertical: 25), padding: .zero)
        let items = photoArray.map { [weak self] photoArray in
            MainScreenViewModel(photoArray)
                .onSelect { [weak self] viewModel in
                    print("name: \(viewModel.model.name)")
            }
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    
    
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
    
    func getMainPageFolders(){
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PicturedObject", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error?.localizedDescription as Any)
                
                //hud.hide(for: self.view, animated: true)
            }
            else {
                //print(results)
                
//                for result in results! {
//                    self.arrayDetails.append(result)
//                }
                
                OperationQueue.main.addOperation({ () -> Void in
                    //self.tableView.reloadData()
                    //self.tableView.isHidden = false
                    //Progress.hide(for: self.view, animated: true)
                })
            }
        }
    }


}

