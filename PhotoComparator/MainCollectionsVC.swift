//
//  MainCollectionsVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/19/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

public enum PHOTO_STORAGE_TYPE {
    case cloud
    case local
}

class MainCollectionsVC: CollectionViewController, DropDownProtocol {
    
    
    var photoArray: Array<MainScreenModel> = []
    var collectionFolders: Array<CollectionFolderModel> = []

    
    var optionViewFrame = DropDownStorageOptionTableView()
    let storageOptionView = DropDownStorageOptionView() //title of nav controller
    var optionViewHeightConstraint = NSLayoutConstraint()
    var isOptionMenuOpen: Bool = false
    
    var refreshButton = UIBarButtonItem()
    
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init()
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView.backgroundColor = .dynamicBackground()
        
        self.collectionView.register(MainScreenCell.self, forCellWithReuseIdentifier: "MainScreenCell")
        
        optionViewFrame.delegate = self
        setupImportPhotoButton()
        setupStorageTitleOptionView()
        optionViewFrame.dropDownOptions = ["CloudKit Storage","Local Storage"]
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        photoArray.removeAll()
        getStorageTypeFromMemory() //dataSource from cloud or local mem
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        self.navigationItem.titleView = storageOptionView
        self.navigationItem.leftBarButtonItem = refreshButton
        self.navigationController?.navigationBar.isHidden = false
        tutorialViewSetup()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tutorialView.removeFromSuperview()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    var tutorialView = Tutorial_View()
    
    
    //MARK: Tutorial View
    func tutorialViewSetup(){
        if (UserDefaults.standard.getTutorialDefault(tutorialType: .album) == "show"){
            //if show tutorial is true
            tutorialView = Tutorial_View(frame: self.view.frame, tutorialTextID: .addAlbum)
            tutorialView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tutorialView)
            self.tutorialView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.tutorialView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.tutorialView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tutorialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.view.bringSubviewToFront(tutorialView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTutorialView))
            self.tutorialView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissTutorialView(){
        self.tutorialView.removeFromSuperview()
    }
    
    //MARK: Storage Type functions
    func getStorageTypeFromMemory(){
        if (getUserDefaultStorageType() == "Cloud"){
            storageOptionView.viewText.text = "CloudKit Storage"
            getPhotoData_From(.cloud)
        }
        else{
            storageOptionView.viewText.text = "Local Storage"
            getPhotoData_From(.local)
        }


    }
    
    func getPhotoData_From(_ type: PHOTO_STORAGE_TYPE){
        switch type {
        case .cloud:
            setupRefreshButton()
            getCKCollectionFolderInfo()
            break
        case .local:
            setupRefreshButton()
            getImagesFromCoreData()
            OperationQueue.main.addOperation({ () -> Void in
                self.setFetchedDataToCells()
                self.collectionView.reloadData()
            })
            
            break
        }
    }
    
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
    
    func setUserDefaultStorageType(_ type: String){
        UserDefaults.standard.setDefaultStorageType(value: type)
    }
    
    
    //MARK: Fetch Data From CloudKit
    
    func getCKCollectionFolderInfo(){
        
        guard let unwrappedCollectionPhotoArray = self.cloudkitOperations?.collectionFolderArray else {return}
        self.collectionFolders = unwrappedCollectionPhotoArray
        guard let unwrappedPhotoArray = self.cloudkitOperations?.photoArray else {return}
        self.photoArray = unwrappedPhotoArray
        
        OperationQueue.main.addOperation({ () -> Void in
            self.setFetchedDataToCells()
            self.collectionView.reloadData()
        })
    }
    
    //MARK: Fetch Data from CoreData
    
    func getImagesFromCoreData(){
        self.coreDataFunctions?.getMainPageCollectionFolders()
        guard let unwrappedPhotoArray = self.coreDataFunctions?.photoArray else {return}
        self.photoArray = unwrappedPhotoArray
    }
    

    
    //MARK: Cell Setup
    
    func setFetchedDataToCells(){
        //didSelectRow
        self.photoArray.sort{$0.name<$1.name}
        let grid = Grid(columns: 2, margin: UIEdgeInsets(horizontal: 0, vertical: 25), padding: .zero)
        let items = photoArray.map { [weak self] photoArray in
            MainScreenViewModel(photoArray)
                .onSelect { [weak self] viewModel in
                    let collectionViewController = PhotoCollectionVC(coreDataFunctions: self!.coreDataFunctions!, cloudKitOperations: self!.cloudkitOperations!)

                    let date = viewModel.model.date
                    let photo = viewModel.model.image
                    let id = viewModel.model.id
                    let name = viewModel.model.name
                    //MARK: Present Collection VC
                    collectionViewController.photoModel = PhotoCollectionObject(date: date, photo: photo, id: id, name: name, ckrecordID: CKRecord.ID(recordName: "foo"), hideBlurView: true)

                    collectionViewController.cloudkitOperations = self!.cloudkitOperations!
                    
                    collectionViewController.collectionNameUID = viewModel.model.nameUID
                    let nameUID = viewModel.model.nameUID
                    //sending ckRecord of collection folder data
                    if let folderIdx = self?.collectionFolders.firstIndex(where: {$0.nameUID as String == nameUID}) {
                        collectionViewController.collectionFolder_CKRecord = self?.collectionFolders[folderIdx].cKRecord
                    }
                    self?.show(collectionViewController, sender: nil)
            }
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    
    //MARK: Nav Button Setup
    func setupStorageTitleOptionView(){
        storageOptionView.isUserInteractionEnabled = true

        self.view.addSubview(optionViewFrame)
        self.view.bringSubviewToFront(optionViewFrame)
        optionViewFrame.translatesAutoresizingMaskIntoConstraints = false
        optionViewFrame.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 2).isActive = true
        optionViewFrame.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        optionViewFrame.widthAnchor.constraint(equalToConstant: 400).isActive = true
        optionViewHeightConstraint = optionViewFrame.heightAnchor.constraint(equalToConstant: 0)
        
        storageOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(storageButtonPressed)))
     
    }
    
    //MARK: Storage title button pressed
    @objc func storageButtonPressed(){
        isOptionMenuOpen.toggle()
        if isOptionMenuOpen{
            //menu open
            storageOptionView.changeArrowDirection(direction: .up)
            NSLayoutConstraint.deactivate([self.optionViewHeightConstraint])
//            if (self.optionViewFrame.tableView.contentSize.height > 100) {
//                self.optionViewHeightConstraint.constant = 100
//            }
//            else {
                self.optionViewHeightConstraint.constant = self.optionViewFrame.tableView.contentSize.height
//            }
            
            NSLayoutConstraint.activate([self.optionViewHeightConstraint])
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.optionViewFrame.layoutIfNeeded()
                self.optionViewFrame.center.y += self.optionViewFrame.frame.height / 2
            }, completion: nil)
        }
        else {
            //menu closed
            dismissStorageDropDownMenu()
        }
    }
    
    @objc func dismissStorageDropDownMenu(){
        //menu closed
        isOptionMenuOpen = false
        storageOptionView.changeArrowDirection(direction: .down)
        NSLayoutConstraint.activate([self.optionViewHeightConstraint])
        self.optionViewHeightConstraint.constant = 0
        
        NSLayoutConstraint.deactivate([self.optionViewHeightConstraint])
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.optionViewFrame.center.y -= self.optionViewFrame.frame.height / 2
            self.optionViewFrame.layoutIfNeeded()
        }, completion: nil)
    }

    //MARK: PROTOCOL
    func dropDownPressed(string: String) {
        self.photoArray.removeAll()
        self.setFetchedDataToCells()
        storageOptionView.viewText.text = string
        if (string == "CloudKit Storage"){
            setUserDefaultStorageType("Cloud")
            getStorageTypeFromMemory()
        }
        else{
            setUserDefaultStorageType("Local")
            getStorageTypeFromMemory()
        }
        self.dismissStorageDropDownMenu()
    }
    
    
    //MARK: Refresh button
    func setupRefreshButton(){
        refreshButton = UIBarButtonItem(title: ionicon.Refresh.rawValue, style: .plain, target: self, action: #selector(refreshButtonAction))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        refreshButton.tintColor = .secondaryColor()
        refreshButton.setTitleTextAttributes(attributes, for: .normal)
        refreshButton.setTitleTextAttributes(attributes, for: .highlighted)
    }
    
    @objc func refreshButtonAction(){
        print("refresh")
        if (getUserDefaultStorageType() == "Cloud"){
            photoArray.removeAll()
            getCKCollectionFolderInfo()
        }
        else {
            photoArray.removeAll()
            getImagesFromCoreData()
        }
        
        OperationQueue.main.addOperation({ () -> Void in
             self.setFetchedDataToCells()
             self.collectionView.reloadData()
        })
    }
    
    //MARK: Import photos
    func setupImportPhotoButton(){
        let importButton = UIBarButtonItem(title: ionicon.AndroidAdd.rawValue, style: .plain, target: self, action: #selector(importPhotoButtonAction))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        importButton.tintColor = .secondaryColor()
        importButton.setTitleTextAttributes(attributes, for: .normal)
        importButton.setTitleTextAttributes(attributes, for: .highlighted)
        
        navigationItem.rightBarButtonItem = importButton
    }
    
    @objc func importPhotoButtonAction(){
        var newAlbumName: String = ""
        
        let prompt = UIAlertController(title: "New Album", message: "Please input the name of your new photo album", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            newAlbumName = textField.text ?? ""
            
            let photoImportVC = PhotoImportVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)

            photoImportVC.newCollectionName = newAlbumName
            photoImportVC.title = "\(newAlbumName)"
            photoImportVC.photoUploadOperations(operation: .newCollection, uid: nil)
            self.navigationController?.pushViewController(photoImportVC, animated: true)
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Album Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(prompt, animated: true, completion: nil)
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
    
//    func nukeFolders(){
//        let container = CKContainer.init(identifier: "iCloud.victoryCloud.PhotoComparator")
//        let privateDatabase = container.privateCloudDatabase
//
//        let query = CKQuery(recordType: "CollectionFolder", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
//        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
//
//            if error == nil {
//
//                for record in records! {
//
//                    privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordId, error) in
//
//                        if error == nil {
//
//                            //Record deleted
//                            print("record delted")
//                        }
//
//                    })
//
//                }
//
//            }
//
//        }
//    }
}

//590980952





