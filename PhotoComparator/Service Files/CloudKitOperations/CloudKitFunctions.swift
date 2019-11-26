//
//  CloudKitFunctions.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/12/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import CloudKit


class CloudKitFunctions {
    
    var photoObjectArray:[PicturedObject] = [] //array of picturedObjects to upload
    var collectionFolderArray:[CollectionFolderModel] = [] //array of folder information
    
    var photoArray: Array<MainScreenModel> = [] //array to return to populate main screen cells
    var imageURL: URL!
    var firstObjectTimestampIDforCoreData:String = "" //setting uid for use with core data
    var ckErrorHandle = CloudKitError()
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    //, completionHandler:@escaping (_ completed: Bool)-> Void
    
    func getTimestampID() -> String {
        return firstObjectTimestampIDforCoreData
    }
    
    func uploadPhotoObjectArray(photoArray: [PicturedObject]){
        self.photoObjectArray = photoArray
        uploadObjectsToCloudKit()
    }

    //MARK: Preparing photos for upload
    
    private func uploadObjectsToCloudKit(){
        
        for (index, picturedObject) in photoObjectArray.enumerated() {
             
             let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
             
             let imageData = picturedObject.photo.jpegData(compressionQuality: 0.8)
             let path = documentsDirectoryPath.appendingPathComponent("tempImgName"+"\(String(index))"+".jpg")
             imageURL = URL(fileURLWithPath: path)
             do {
                 try imageData?.write(to: imageURL as URL)
                 saveSaveURL_CK(picturedObject: picturedObject, index: index)
             } catch let error as NSError {
                 print("photo upload write to URL Failed. Underlying error \(error)")
             }
             
             if let url = imageURL {
                 let fileManager = FileManager()
                 if fileManager.fileExists(atPath: url.absoluteString) {
                     do {
                         try fileManager.removeItem(atPath: url.absoluteString)}
                     catch let error as NSError {
                         print("Error deleting url from fileManager: \(error.localizedDescription)")
                     }
                 }
                 self.imageURL = nil
             }
         }
    }
    
    //MARK: Saving to CloudKit
    
    private func saveSaveURL_CK(picturedObject: PicturedObject, index: Int){
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

        if (photoObjectArray[0].date == picturedObject.date){
            //if first date and oldest picture, use as photo folder header
            self.firstObjectTimestampIDforCoreData = String(timestampParts[0])
        }
        
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.save(picturedObjectRecord) { (record, error) -> Void in
            if let error = error{
                if let ckError = error as? CKError {
                    self.ckErrorHandle.handle_CKError(ckError: ckError.code)
                }
            }
            else {
                print("CK Save Success")
            }
        }
    }
    
    //MARK: Delete collection
    
    func deleteCollection(photoArray: [PhotoCollectionObject]){
        
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        for item in photoArray {
            privateDatabase.delete(withRecordID: item.ckrecordID, completionHandler: {recordID, error in
                if let error = error{
                    if let ckError = error as? CKError {
                        self.ckErrorHandle.handle_CKError(ckError: ckError.code)
                    }
                }
                else {
                    print("CK collection successfully deleted")
                }
            })
        }
    }
    
    //MARK: Delete record
    
    func deleteRecord(photo: PhotoCollectionObject){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        privateDatabase.delete(withRecordID: photo.ckrecordID, completionHandler: {recordID, error in
                if let error = error{
                    if let ckError = error as? CKError {
                        self.ckErrorHandle.handle_CKError(ckError: ckError.code)
                    }
                }
                else {
                    print("CK record successfully deleted")
                }
        })
    }
    
    //MARK: New CollectionFolder Object
    
    func setFolderInfo(folderName: NSString, nameUID: NSString, recordID: NSString){

        let noteID = CKRecord.ID()
        let collectionFolder = CKRecord(recordType: "CollectionFolder", recordID: noteID)
        collectionFolder.setValue(folderName, forKey: "name")
        collectionFolder.setValue(nameUID, forKey: "nameUID")
        collectionFolder.setValue(recordID, forKey: "picturedObjectRecordID")
        
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.save(collectionFolder) { (record, error) -> Void in
            if let error = error{
                if let ckError = error as? CKError {
                    self.ckErrorHandle.handle_CKError(ckError: ckError.code)
                }
            }
            else {
                print("ColelctionFolder CK Save Success")
            }
        }
    }
    
    //MARK: Get Main Page Folders
    
    func getMainPageFolders(completionHandler:@escaping (_ collectionFolders: [CollectionFolderModel]?)-> Void){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true) //Get all collection folders
        let query = CKQuery(recordType: "CollectionFolder", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
           if let error = error{
               if let ckError = error as? CKError {
                    print("CloudKitFunctions: getMainPageFolders()")
                    self.ckErrorHandle.handle_CKError(ckError: ckError.code)
               }
           }
           else {
               for result in results! {
                guard let nameUID = result.value(forKey: "nameUID") as? NSString else {print("1"); return}
                guard let name = result.value(forKey: "name") as? NSString else {print("2"); return}
                guard let recordID = result.value(forKey: "picturedObjectRecordID") as? NSString else {print("3"); return}

                    if !(self.collectionFolderArray.contains(where: {$0.nameUID == nameUID})){
                        //unique records only
                        let folder = CollectionFolderModel(name: name, nameUID: nameUID, picturedObjectRecordID: recordID)
                        self.collectionFolderArray.append(folder)
                    }
                }
            completionHandler(self.collectionFolderArray)
            }
       }
    }
    
    func getCollectionFolderRecords(_ collectionModelArray: [CollectionFolderModel], completionHandler : @escaping ((_ mainFolders:Array<MainScreenModel>?) -> Void)){
        var recordIDs: [CKRecord.ID] = []
        for record in collectionModelArray {
            recordIDs.append(CKRecord.ID(recordName: record.picturedObjectRecordID as String))
        }
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(format: "NOT (recordID IN %@)", recordIDs) // CD array
        let query = CKQuery(recordType: "PicturedObject", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
           if let error = error{
            print("ckf: \(error.localizedDescription)")
               if let ckError = error as? CKError {
                    print("CloudKitFunctions: getCloudKitRecordFromID()")
                    self.ckErrorHandle.handle_CKError(ckError: ckError.code)
               }
           }
           else {
                for result in results! {
                    guard let id = result.value(forKey: "id") as? String else {return}
                    if !(self.photoArray.contains(where: {$0.id == id})){
                        //unique records only
                        var name = ""
                        if let index = collectionModelArray.firstIndex(where: {$0.nameUID as String == id}) {
                            name = collectionModelArray[index].name as String
                        }
                        let imageAsset: CKAsset = result.value(forKey: "photo") as! CKAsset
                        let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                        let date = result.value(forKey: "date") as? NSDate
                        self.photoArray.append(MainScreenModel(name: name, image: image!, id: id, date: date!, nameUID: ""))
                    }
                }
            completionHandler(self.photoArray)
            }
        }
    }


}
