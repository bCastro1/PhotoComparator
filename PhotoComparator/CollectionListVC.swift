//
//  CollectionListVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/31/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CollectionListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var collectionFolderTableView: UITableView!
    var imageToSave: UIImage!
     
    var photoArray: Array<MainScreenModel> = [] //folder info array
    var photoArray_SearchDuplicate: Array<MainScreenModel> = []
    var newCollectionName: String!
    

    //MARK: Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionFolderTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        collectionFolderTableView.delegate = self
        collectionFolderTableView.dataSource = self
        collectionFolderTableView.keyboardDismissMode = .onDrag
        self.view.backgroundColor = UIColor.white
        
        setupViews()
        navigationBarSetup()
        searchBarSetup()
        getCollectionFolderNames()
    }
    
    //MARK: Navigation bar setup
    func navigationBarSetup(){
        let addFolderButton = UIBarButtonItem(title: ionicon.iOSPlus.rawValue, style: .plain, target: self, action: #selector(newFolderButtonPressed))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        addFolderButton.tintColor = self.view.tintColor
        addFolderButton.setTitleTextAttributes(attributes, for: .normal)
        addFolderButton.setTitleTextAttributes(attributes, for: .highlighted)
        self.navigationItem.rightBarButtonItem = addFolderButton
    }
    
    //MARK: New folder action
    @objc func newFolderButtonPressed(){
        let prompt = UIAlertController(title: "New Collection", message: "Name of your new photo collection", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            self.newCollectionName = textField.text ?? ""
            self.title = self.newCollectionName
            
            let photoImportVC = PhotoImportVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)

            photoImportVC.title = self.newCollectionName
            photoImportVC.newCollectionName = self.newCollectionName
            photoImportVC.mergedPhotoToUpload = self.imageToSave
            photoImportVC.photoUploadOperations(operation: .singlePhoto_New_CollectionAddition)
            self.navigationController?.pushViewController(photoImportVC, animated: true)
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Collection Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(prompt, animated: true, completion: nil)
    }
    
    //MARK: Storage type; get names
    
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
    
    func getCollectionFolderNames(){
        if (getUserDefaultStorageType() == "Cloud"){
            getCloudKitCollectionNames()
        }
        else{
            getCoreDataCollectionNames()
        }
    }
    
    //MARK: Get CD collection names
    private func getCoreDataCollectionNames(){
        guard let unwrappedPhotoArray = self.coreDataFunctions?.photoArray else {return}
        self.photoArray = unwrappedPhotoArray
        self.photoArray.sort{$0.name<$1.name} //alphabetize
        self.photoArray_SearchDuplicate = self.photoArray
        collectionFolderTableView.reloadData()
    }
    
    //MARK: Get CK collection names
    private func getCloudKitCollectionNames(){
        guard let phoArray = self.cloudkitOperations?.photoArray else {return}
        self.photoArray = phoArray
        self.photoArray.sort{$0.name<$1.name}
        self.photoArray_SearchDuplicate = self.photoArray
        collectionFolderTableView.reloadData()
    }
    
    
    //MARK: View setup
    func setupViews(){
        self.view.addSubview(collectionFolderTableView)
        collectionFolderTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionFolderTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionFolderTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        collectionFolderTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionFolderTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }

    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.photoArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoImportVC = PhotoImportVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
        
        let photoModel = photoArray[indexPath.row]
        photoImportVC.UID = photoModel.nameUID as NSString
        photoImportVC.mergedPhotoToUpload = imageToSave
        photoImportVC.photoUploadOperations(operation: .singlePhoto_Existing_CollectionAddition)
        photoImportVC.newCollectionName = photoModel.name
        photoImportVC.title = "\(photoModel.name)"
        photoImportVC.shouldWaitToSetupCells = true
        self.navigationController?.pushViewController(photoImportVC, animated: true)
    }

    
    //MARK: Search Bar setup
    func searchBarSetup(){
        //constraints and setup for search bar
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 70))
        self.collectionFolderTableView.tableHeaderView = searchBar
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty){
            self.photoArray = self.photoArray_SearchDuplicate
            self.collectionFolderTableView.reloadData()
        }
        else {
            filterTableWithSearch(text: searchText)
        }
    }
    
    func filterTableWithSearch(text: String){
        photoArray = self.photoArray_SearchDuplicate.filter({ (collection) -> Bool in
            return (collection.name.lowercased().contains(text.lowercased()))
        })
        self.collectionFolderTableView.reloadData()
    }
}
