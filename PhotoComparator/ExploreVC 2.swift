//
//  ExploreVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

class ExploreVC: CollectionViewController {

    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    var explorePhotos: Array<ExploreModel> = []
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        self.collectionView.register(ExploreCell.self, forCellWithReuseIdentifier: "ExploreCell")
        getALLMainPageFolders()
        //getUserInfo()
        
        
        // call the function above in the following way:
        // (userID is the string you are interested in!)
        cloudkitOperations!.iCloudUserIDAsync { (recordID: CKRecord.ID?, error: NSError?) in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
            } else {
                print("Fetched iCloudID was nil")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Explore"
    }
    
    func getALLMainPageFolders(){
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SharedPhoto", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (result, error) -> Void in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                for record in result! {
                    let imageAsset: CKAsset = record.value(forKey: "photo") as! CKAsset
                        let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                    let id = record.recordID.recordName
                    self.explorePhotos.append(ExploreModel(image: image!, rating: 1, id: id, date: NSDate()))
                    }
                }
                OperationQueue.main.addOperation { () -> Void in
                    self.setFetchedDataToCells()
                    self.collectionView.reloadData()
                }
            }
        }
    
    
    
    
    //MARK: Cell Setup
    
    func setFetchedDataToCells(){
        //laying out selected photos to cells
        //self.progressTotal = self.photoObjectArray.count
        let grid = Grid(columns: 4, margin: UIEdgeInsets(all: 8), padding: .zero)
        let itemsToDisplay = self.explorePhotos.map { ExploreViewModel($0)}
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: itemsToDisplay)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    
    
    func getUserInfo(){
        
        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
        let privateDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (result, error) -> Void in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                for record in result! {
                    if let recName = record.value(forKey: "userID") as? String {
                        print("userID: \(recName)")
                    }
                    else {
                        print("nah")
                    }
                }
                OperationQueue.main.addOperation { () -> Void in
                    //self.setFetchedDataToCells()
//self.collectionView.reloadData()
                }
            }
        }
        
        
    }
}
    



    
//    func printMessagesForUser() -> Void {
//        let json = ["user":"larry"]
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//            //let url = NSURL(string: "http://127.0.0.0/api/get_messages")! //test
//            let url = NSURL(string: "http://3.101.19.216/api/get_messages")! //aws
//            let request = NSMutableURLRequest(url: url as URL)
//            request.httpMethod = "POST"
//            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            request.httpBody = jsonData
//            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
//                if error != nil{
//                    print("Error -> \(error)")
//                    return
//                }
//                do {
//                    if let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject] {
//                        print("Result -> \(result)")}
//                } catch {
//                    print("Error -> \(error)")
//                }
//            }
//            task.resume()
//        } catch {
//            print(error)
//        }
//    }

