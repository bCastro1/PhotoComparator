//
//  Import_NewCollection.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/23/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation

extension PhotoImportVC {
    
    //MARK: brand new collection
    func newCollectionUpload(UID: NSString){
        
        uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadButtonPressed))
        self.navigationItem.rightBarButtonItem = uploadButton
        self.importButtonDisplayPicker.addTarget(self, action: #selector(newPhotoImportAction), for: .touchUpInside)
        //let user choose to upload from camera or colleciton
        self.setupImportPhotoButton()
    }
    
    //MARK: adding to existing collection
    func existingCollectionUpload(UID: NSString){
        
        uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadButtonPressed))
        self.navigationItem.rightBarButtonItem = uploadButton
        self.setupImportPhotoButton()
        self.importButtonDisplayPicker.addTarget(self, action: #selector(existingPhotoImportAction), for: .touchUpInside)
    }
    
    //MARK: adding merged photo to NEW colleciton
    func merged_NewCollectionUpload(UID: NSString){
        uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadButtonPressed))
        self.navigationItem.rightBarButtonItem = uploadButton
        self.shouldWaitToSetupCells = true
        
        if (mergedPhotoToUpload != nil){
            let picturedObject = PicturedObject(
                 date: Date() as NSDate,
                 photo: mergedPhotoToUpload,
                 id: UID)
            self.photoObjectArray.append(picturedObject)
        }
    }
    
    //MARK: adding merged photo to EXISTING colleciton
    func merged_ExistingCollectionUpload(UID: NSString){
        uploadButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadButtonPressed))
        self.navigationItem.rightBarButtonItem = uploadButton
        self.shouldWaitToSetupCells = true
        if (mergedPhotoToUpload != nil){
            let picturedObject = PicturedObject(
                 date: Date() as NSDate,
                 photo: mergedPhotoToUpload,
                 id: UID)
            self.photoObjectArray.append(picturedObject)
        }
    }
    
    //MARK: Error handling
    
    @objc func uploadButtonPressed() {
        self.dismissTutorialView()
        do {
            try pageCompletionCheck_FinishUpload(operation: uploadOperationType)
        }
        catch pageCompletionError.invalidNameLength {
            print("error length: \(self.newCollectionName.count) ")
            let notice = UIAlertController(title: "Error", message: "Proposed group names must be between 6 and 36 characters.", preferredStyle: .alert)
            notice.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { handler in
                self.getNewCollectionNameFromUser()
            }))
            notice.addAction(UIAlertAction(title: "Cancel Upload", style: .destructive, handler: { handler in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(notice, animated: true, completion: nil)
        }
        catch pageCompletionError.invalidPicture {
            print("err: pic")
            showSimpleAlertWithTitle("Picture Error", message: "You must upload at least one photo.", viewController: self)
        }
        catch {
            showSimpleAlertWithTitle("Error", message: "An internal error occurred. Please try again later.", viewController: self)
            print("err: unexpected")
        }
    }
    
    //MARK: finishUploadProcess
    func pageCompletionCheck_FinishUpload(operation: importOperationType) throws {
        //character count between 6-24 chars
        guard newCollectionName.count <= 36 && newCollectionName.count >= 6 else {
            throw pageCompletionError.invalidNameLength
        }
        
        //user must upload images
        guard !photoObjectArray.isEmpty else {
            throw pageCompletionError.invalidPicture
        }
        //start upload
        
        progressView.isHidden = false
        progressTotal = photoObjectArray.count
        
        switch operation {
            
        case .newCollection:
            if (getUserDefaultStorageType() == "Cloud"){
                //cloudKit upload
                self.cloudkitOperations?.uploadPhotoObjectArray(photoArray: photoObjectArray)
                self.cloudkitOperations?.setFolderInfo(folderName: self.newCollectionName as NSString, nameUID: self.UID, recordID: self.cloudkitOperations!.getTimestampID() as NSString)
            }
            else {
                //core data upload
                self.coreDataFunctions?.savePicturedObjectCollection(photoObjectArray: photoObjectArray, nameUID: self.UID as String)
                self.coreDataFunctions?.saveNewCollectionInfo(collectionName: self.newCollectionName, nameUID: self.UID as String)
            }
            break
            
        case .existingCollection:
            if (getUserDefaultStorageType() == "Cloud"){
                //cloudKit upload
                self.cloudkitOperations?.uploadPhotoObjectArray(photoArray: photoObjectArray)
            }
            else {
                //core data upload
                self.coreDataFunctions?.savePicturedObjectCollection(photoObjectArray: photoObjectArray, nameUID: self.UID as String)
            }
            break
            
        case .singlePhoto_Existing_CollectionAddition:
            if (getUserDefaultStorageType() == "Cloud"){
                //cloudKit upload
                self.cloudkitOperations?.uploadPhotoObjectArray(photoArray: photoObjectArray)
            }
            else {
                //core data upload
                self.coreDataFunctions?.savePicturedObjectCollection(photoObjectArray: photoObjectArray, nameUID: self.UID as String)
            }
            break
            
        case .singlePhoto_New_CollectionAddition:
            if (getUserDefaultStorageType() == "Cloud"){
                //cloudKit upload
                self.cloudkitOperations?.uploadPhotoObjectArray(photoArray: photoObjectArray)
                self.cloudkitOperations?.setFolderInfo(folderName: self.newCollectionName as NSString, nameUID: self.UID, recordID: cloudkitOperations!.getTimestampID() as NSString)
            }
            else {
                //core data upload
                self.coreDataFunctions?.savePicturedObjectCollection(photoObjectArray: photoObjectArray, nameUID: self.UID as String)
                self.coreDataFunctions?.saveNewCollectionInfo(collectionName: self.newCollectionName, nameUID: self.UID as String)
            }
            break
        }
        
        UserDefaults.standard.setTutorialDefault(value: "hide", tutorialType: .album)
    }
    
    
}
