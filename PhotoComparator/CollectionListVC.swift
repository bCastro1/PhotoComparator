//
//  CollectionListVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/31/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation

class CollectionListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var collectionFolderTableView: UITableView!
    var cloudkitOperations = CloudKitFunctions()
    var imageToSave: UIImage!
     
    var photoArray: Array<MainScreenModel> = [] //folder info array
    var photoArray_SearchDuplicate: Array<MainScreenModel> = []
    var newCollectionName: String!
    
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
        getCloudKitCollectionNames()
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
    
    @objc func newFolderButtonPressed(){
        let prompt = UIAlertController(title: "New Collection", message: "Please input the name of your new photo collection", preferredStyle: .alert)
        
        let getInput = UIAlertAction(title: "Next", style: .default, handler: {
            alert -> Void in
            let textField = prompt.textFields![0] as UITextField
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .default
            self.newCollectionName = textField.text ?? ""
            self.title = self.newCollectionName
        })
        prompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Photo Collection Name" }
        prompt.addAction(getInput)
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(prompt, animated: true, completion: nil)
    }
    
    //MARK: Get CK collection names
    func getCloudKitCollectionNames(){
        self.photoArray = self.cloudkitOperations.photoArray
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
        let photoImportVC = PhotoImportVC(nibName: nil, bundle: nil)
        let photoModel = photoArray[indexPath.row]
        photoImportVC.cloudkitOperations = self.cloudkitOperations
        photoImportVC.UID = photoModel.id as NSString
        photoImportVC.mergedPhotoToUpload = imageToSave
        photoImportVC.photoUploadOperations(operation: .singlePhotoCollectionAddition)
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
