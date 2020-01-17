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
import UIKit

protocol CoreDataSaveProtocol {
    var progressTotal: Int { get set }
    func saveProgess(progressInt: Int)
}

class CoreDataFunctions {
  //Core Data Service Class
    var context: NSManagedObjectContext! = nil
    var conversion_Queue = DispatchQueue(label: "ConversionQueue")
    var save_Queue = DispatchQueue(label: "SaveQueue")
    var photoArray: [MainScreenModel] = [] //main screen vc
    var collectionPhotoArray: [PhotoCollectionObject] = []
    var collectionArray: [PhotoCollectionObject] = [] //collection vc
    var collectionFolder_PictureID: String = ""
    var delegate: CoreDataSaveProtocol!
    
    func setAssets(_ context: NSManagedObjectContext){
        self.context = context
        conversion_Queue.sync {
            print("conversionQueue")
        }
        save_Queue.sync {
            print("saveQueue")
        }
    }
    
    func getGuardedContext_setAssets() throws {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        context = appDelegate.persistentContainer.viewContext
        
        conversion_Queue.sync {
            print("conversionQueue")
        }
        save_Queue.sync {
            print("saveQueue")
        }
    }
    
    //MARK: Save collection array
    
    func savePicturedObjectCollection(photoObjectArray: [PicturedObject], nameUID: String){
        
        for (index, picture) in photoObjectArray.enumerated() {
            let picID = getTimestampIdentifierWithIndex(idx: index)
            prepareImageForCoreData(picture: picture, pictureID: picID, nameUID: nameUID, idx: index)
            if (index == 0){
                //first idx
                collectionFolder_PictureID = picID
            }
        }
    }
    
    //MARK: preparing image for CD
    private func prepareImageForCoreData(picture: PicturedObject, pictureID: String ,nameUID: String, idx: Int){
        conversion_Queue.async {
            guard let fullResImageData = picture.photo.jpegData(compressionQuality: 1)
                else {
                    print("jpeg conversion err")
                    return
            }
            
            self.savePicturedObject(pictureID: pictureID, nameUID: nameUID, imageData: fullResImageData, date: picture.date as Date, idx: idx)
        }
    }
    
    private func savePicturedObject(pictureID: String, nameUID: String, imageData: Data, date: Date, idx: Int){
        
        save_Queue.sync {
            guard let fullResolutionObject = NSEntityDescription.insertNewObject(forEntityName: "FullResolution", into: context) as? FullResolution else {
                print("moc error")
                return
            }
            fullResolutionObject.imageData = imageData
            fullResolutionObject.date = date
            fullResolutionObject.id = pictureID
            fullResolutionObject.nameUID = nameUID
            
            do {
                try context.save()
                print("CD object saved!")
                delegate.saveProgess(progressInt: idx)
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            context.refreshAllObjects()
        }
    }
    
    //MARK: Load main page folders
    
    func getMainPageCollectionFolders(){
        self.photoArray.removeAll()
        var collectionFoldersFromCoreData: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"CollectionNameInfo")
        do {
            collectionFoldersFromCoreData = try context.fetch(fetchRequest)
            for folder in collectionFoldersFromCoreData {
                guard let name = folder.value(forKey: "name") as? String else { return }
                guard let nameUID = folder.value(forKey: "nameUID") as? String else { return }
                guard let pictureID = folder.value(forKey: "pictureID") as? String else { return }
                
                self.loadImageWithID(collectionFolderID: pictureID, nameUID: nameUID, name: name)
            }
        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    //MARK: Load Image w ID
    
    func loadImageWithID(collectionFolderID: String, nameUID: String, name: String){
        do {
            let fetchRequest: NSFetchRequest<FullResolution> = FullResolution.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", collectionFolderID)
            let fetchedResults = try context.fetch(fetchRequest)
            if let photo = fetchedResults.first {
                guard let date = photo.value(forKey: "date") as? NSDate else {return}
                guard let pictureData = photo.value(forKey: "imageData") as? NSData else {return}
                guard let image = UIImage(data: pictureData as Data) else {return}
                let collectionFolderModel = MainScreenModel(name: name, image: image, id: collectionFolderID, date: date, nameUID: nameUID)
                self.photoArray.append(collectionFolderModel)
            }

        }
        catch let error as NSError {
            print("Error fetching single record with id CoreData: \(error.localizedDescription)")
        }
    }

    //MARK: LoadCollection w UID
    
    func loadCollectionWithNameUID(nameUID: String, collectionName: String){
        self.collectionPhotoArray.removeAll()
        var photosFromCoreData: [NSManagedObject] = []
        do {
            let fetchRequest: NSFetchRequest<FullResolution> = FullResolution.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nameUID == %@", nameUID)
            photosFromCoreData = try context.fetch(fetchRequest)
            
            for photo in photosFromCoreData {
                guard let pictureData = photo.value(forKey: "imageData") as? NSData else {return}
                guard let image = UIImage(data: pictureData as Data) else {return}
                guard let pictureID = photo.value(forKey: "id") as? String else {return}
                guard let date = photo.value(forKey: "date") as? Date else {return}
                
                collectionPhotoArray.append(PhotoCollectionObject(date: date as NSDate, photo: image, id: pictureID, name: collectionName, ckrecordID: CKRecord.ID(recordName: pictureID), hideBlurView:    true))
            }

        } catch let error as NSError {
            print("Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Save Main page folder with name
    func saveNewCollectionInfo(collectionName: String, nameUID: String){
        //name, nameUID, pictureID
        
        save_Queue.sync {
            guard let collectionNameObject = NSEntityDescription.insertNewObject(forEntityName: "CollectionNameInfo", into: context) as? CollectionNameInfo else {
                print("collectionNameInfo MOC error")
                return
            }
            collectionNameObject.name = collectionName
            collectionNameObject.nameUID = nameUID
            collectionNameObject.pictureID = collectionFolder_PictureID
            
            do {
                try context.save()
                print("collectionNameInfo saved!")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            context.refreshAllObjects()
        }
    }
    
    
    //MARK: Upldate colleciton name
    func updateCollectionName(collectionName: String, nameUID: String){
        save_Queue.sync {
            var recordFromCoreData: [NSManagedObject] = []
            do {
                let fetchRequest: NSFetchRequest<CollectionNameInfo> = CollectionNameInfo.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "nameUID == %@", nameUID)
                recordFromCoreData = try context.fetch(fetchRequest)

                if let record = recordFromCoreData.first {
                    record.setValue(collectionName, forKey: "name")
                    do {
                        try context.save()
                        print("collectionNameInfo updated!")
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch let error as NSError {
                print("Error fetching CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func getTimestampIdentifierWithIndex(idx: Int) -> String{
        //creating unique pictureID
        let timestampAsString = String(format: "%f", Date.timeIntervalSinceReferenceDate)
        var timestampParts = timestampAsString.components(separatedBy: ".")
        timestampParts[0] += "-\(idx)"
        return timestampParts[0]
    }
    
    //MARK: Delete single record
    func deleteRecordWithID(id: String){
        do {
            let fetchRequest: NSFetchRequest<FullResolution> = FullResolution.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let fetchedRecord = fetchedResults.first {
                context.delete(fetchedRecord)
                try context.save()
                print("record deleted!")
            }
        }
        catch let error as NSError {
            print("Error deleting single record with id CoreData: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Delete collection
    func deleteCollectionWithUID(uid: String){
        do {
            let fetchRequest: NSFetchRequest<FullResolution> = FullResolution.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nameUID == %@", uid)
            let fetchedResults = try context.fetch(fetchRequest)
            for record in fetchedResults {
                context.delete(record)
            }
            try context.save()
            print("collection deleted")
        }
        catch let error as NSError {
            print("Error deleting collection with id CoreData: \(error.localizedDescription)")
        }
    }
    
    //MARK: Delete main page folder
    func deleteRecordFolderWith_NameUID(_ nameUID: String){
        do {
            let fetchRequest: NSFetchRequest<CollectionNameInfo> = CollectionNameInfo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nameUID == %@", nameUID)
            let fetchedResults = try context.fetch(fetchRequest)
            if let fetchedRecord = fetchedResults.first {
                context.delete(fetchedRecord)
                try context.save()
                print("folder deleted!")
            }
        }
        catch let error as NSError {
            print("Error deleting single folder record with id CoreData: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Development functions
    func nuke(){

        
        
            var photosFromCoreData: [NSManagedObject] = []
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"FullResolution")
            do {
                photosFromCoreData = try context.fetch(fetchRequest)
                for item in photosFromCoreData {
                    context.delete(item)
                    try context.save()
                }
            } catch let error as NSError {
                print("Error fetching CoreData: \(error.localizedDescription)")
            }
    }
    

}
