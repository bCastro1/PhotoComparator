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
    
    var photoObjectArray:[PicturedObject] = []
    var imageURL: URL!
    var firstObjectTimestampIDforCoreData:String = "" //setting uid for use with core data

    
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
            if (error != nil){
                print("Error when saving to CK private database: \(String(describing: error?.localizedDescription))")
            }
            else {
                print("CK Save Success")
            }
        }
    }
    
}
