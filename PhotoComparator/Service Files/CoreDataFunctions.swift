//
//  CoreDataFunctions.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/4/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class CoreDataFunctions {
    //Core Data Service Class
    
    var context: NSManagedObjectContext! = nil
    
    var ckRecordID_RecordIDs: [CKRecord.ID] = []
    var photoNameDictionary:[String:String] = [:]
    
    func setAssets(_ context: NSManagedObjectContext){
        self.context = context
        set_CKFolderReferenceIDs()
        set_CKPhotoNameDictionary()
    }
    
    func getGuardedContext_setAssets() throws {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        context = appDelegate.persistentContainer.viewContext
        
        set_CKFolderReferenceIDs()
        set_CKPhotoNameDictionary()
    }
    
    //MARK: Fetching
    
    private func set_CKFolderReferenceIDs(){
        var ckRecordIDs: [NSManagedObject] = []

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CloudKitRecord")
        do {
            ckRecordIDs = try context.fetch(fetchRequest)
            
            for item in ckRecordIDs {
                if let stringID = item.value(forKey: "id") as? String{
                    if (stringID != ""){
                        self.ckRecordID_RecordIDs.append(CKRecord.ID(recordName: "\(stringID)"))
                    }
                }
            }
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
        
//        for record in ckRecordIDs {
//            if let name = record.value(forKey: "id") as? String {
//                print("id: \(name)")
//            }
//        }
    }
    
    private func set_CKPhotoNameDictionary(){
        var photoNameRecords: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CollectionNameUID")
        do {
            photoNameRecords = try context.fetch(fetchRequest)
            
            //creating dictionary for name values
            for records in photoNameRecords {
                guard let collectionName = records.value(forKey: "name") as? String else {return}
                guard let collectionUID = records.value(forKey: "uid") as? String else {return}
                self.photoNameDictionary[collectionUID] = collectionName
            }
            
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
        
//        for record in photoNameRecords {
//            if let uid = record.value(forKey: "uid") as? String, let name = record.value(forKey: "name") as? String {
//                print("uid: \(uid) - \(name)")
//            }
//        }
    }
    
    //MARK: Saving
    
    func saveNewCollectionName(uid: NSString, newCollectionName: String){
        //"CollectionNameUID" used for translating ckRecordUIDs to a Collection's Name
        
        var collectionName_UIDs: [NSManagedObject] = []
        let entity = NSEntityDescription.entity(forEntityName: "CollectionNameUID", in: context)!
        let valueToStore = NSManagedObject(entity: entity, insertInto: context)
        valueToStore.setValue(uid, forKey: "uid")
        valueToStore.setValue(newCollectionName, forKey: "name")
        do {
          try context.save()
            collectionName_UIDs.append(valueToStore)
            print("Core data object saved. [name-uid]")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveNewRecordID(recordIdentifier: String){
        //"CloudKitRecord" used for storing a collection's first photo for the main page
        
        var ckRecordIDs: [NSManagedObject] = []
        let entity = NSEntityDescription.entity(forEntityName: "CloudKitRecord", in: context)!
        let valueToStore = NSManagedObject(entity: entity, insertInto: context)
        valueToStore.setValue(recordIdentifier, forKey: "id")
        
        do {
          try context.save()
            ckRecordIDs.append(valueToStore)
            print("Core data object saved. [id]")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Deleting
    
    func delete_CKRecordIDAsset(recordIdentifier: String){
        
        var ckRecordIDs: [NSManagedObject] = []

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CloudKitRecord")
        do {
            ckRecordIDs = try context.fetch(fetchRequest)
            
            for item in ckRecordIDs {
                if let stringID = item.value(forKey: "id") as? String{
                    if stringID == recordIdentifier {
                        context.delete(item)
                    }
                }
            }
            do {
                try context.save()
                print("collection data deleted!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Error: CoreDataFunction - delete_CKRecordIDAsset: \(error.localizedDescription)")
        }
    }
    
    func delete_CollectionNameAsset(uid: String){
        
        var photoNameRecords: [NSManagedObject] = []

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CollectionNameUID")
        do {
            photoNameRecords = try context.fetch(fetchRequest)
            
            for item in photoNameRecords {
                if let fetchedUID = item.value(forKey: "uid") as? String{
                    if fetchedUID == uid {
                        context.delete(item)
                    }
                }
            }
            do {
                try context.save()
                print("collection data deleted!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Error: CoreDataFunction - delete_CollectionNameAsset \(error.localizedDescription)")
        }
    }
    
}
