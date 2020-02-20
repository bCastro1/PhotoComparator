//
//  Collage_Step4.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/3/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import CloudKit

class Collage_Step4_PhotoSelection: CollectionViewController {

    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, photoModel: PhotoCollectionObject, collage_Draw: Collage_Draw){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.photoModel = photoModel
        self.photoKeyToQuery = photoModel.id
        self.collage_Draw = collage_Draw
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var collage_Draw: Collage_Draw?
    
    var photoArray: Array<PhotoCollectionObject> = []
    var photoKeyToQuery: String = ""
    var photoModel: PhotoCollectionObject!
    var collectionNameUID: String = ""

    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()

    }

    override func viewWillAppear(_ animated: Bool) {
        if (getUserDefaultStorageType() == "Cloud"){
            fetchRecordFromCloud()
        }
        else {
            fetchCollectionFromCoreData()
        }
    }
    
    //MARK: Core data source
    func fetchCollectionFromCoreData(){
        self.coreDataFunctions?.loadCollectionWithNameUID(nameUID: collectionNameUID, collectionName: photoModel.name)
        guard let unwrappedPhotoArray = self.coreDataFunctions?.collectionPhotoArray else {return}
        self.photoArray = unwrappedPhotoArray
        
        OperationQueue.main.addOperation({ () -> Void in
            self.setupCells()
            self.collectionView.reloadData()
            })
    }
    
    
    //MARK: Cloudkit data source
    func fetchRecordFromCloud(){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.privateCloudDatabase
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
                 self.setupCells()
                 self.collectionView.reloadData()
                 })
            }
        }
    }
    
    //MARK: Setup cells
    func setupCells(){
        self.title = self.photoModel.name
        let items = photoArray.map { [weak self] photoArray in
            PhotoCollectionViewModel(photoArray)
                .onSelect{ [weak self]  viewModel in
                    let collage_step5 = Collage_Step5_Crop(coreDataFunctions: self!.coreDataFunctions!, cloudKitOperations: self!.cloudkitOperations!, originalImage: viewModel.model, collage_Draw: self!.collage_Draw!)
                    collage_step5.modalPresentationStyle = .overFullScreen
                    self?.navigationController?.pushViewController(collage_step5, animated: true)
                }
            }
        
        let grid = Grid(columns: 1, margin: UIEdgeInsets(horizontal: 0, vertical: 35), padding: .zero)
        let photoSection = Section(grid: grid, header: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    
    //MARK: UserDefault StorageType
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
}
    
