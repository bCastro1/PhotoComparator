//
//  CloudKitFunctions_PublicDB.swift
//  
//
//  Created by Brendan Castro on 3/26/20.
//

import Foundation
import CloudKit


extension CloudKitFunctions {
    
    //MARK: Saving to CloudKit
    
    private func saveToPublicDB(picturedObject: PicturedObject, index: Int){
        let timestampAsString = String(format: "%f", Date.timeIntervalSinceReferenceDate)
        //creating uid for CKRecord
        var timestampParts = timestampAsString.components(separatedBy: ".")
        timestampParts[0] += "-\(index)"
        let noteID = CKRecord.ID(recordName: timestampParts[0])
        let picturedObjectRecord = CKRecord(recordType: "SharedPhoto", recordID: noteID)
        picturedObjectRecord.setValue(picturedObject.id, forKey: "id")
        picturedObjectRecord.setValue(1, forKey: "rating")

        if let url = imageURL {
            let imageAsset = CKAsset(fileURL: url)
            picturedObjectRecord.setObject(imageAsset, forKey: "photo")
        }
        else {
            guard let fileURL = Bundle.main.url(forResource: "no_image", withExtension: "png") else { return }
            let imageAsset = CKAsset(fileURL: fileURL)
            picturedObjectRecord.setObject(imageAsset, forKey: "photo")
        }

        //self.firstObjectTimestampIDforCoreData = String(timestampParts[0])

        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        //let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.save(picturedObjectRecord) { (record, error) -> Void in
            if let error = error{
                if let ckError = error as? CKError {
                    self.ckErrorHandle.handle_CKError(ckError: ckError.code)
                }
            }
            else {
                self.delegate.saveProgess(progressInt: index)
                print("CK Public DB Save Success")
            }
        }
    }
    
}
