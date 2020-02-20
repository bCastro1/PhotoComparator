//
//  Collage_Step2b.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/3/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation
import CloudKit


class Collage_Step3_CollectionSelection: CollectionViewController, DropDownProtocol {
    
    //main screen folders
    
    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, collage_Draw: Collage_Draw){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.collage_Draw = collage_Draw
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Variable declaration
    var collage_Draw: Collage_Draw?
    var photoArray: Array<MainScreenModel> = []
    var collectionFolders: Array<CollectionFolderModel> = []
    
    var optionViewFrame = DropDownStorageOptionTableView()
    let storageOptionView = DropDownStorageOptionView() //title of nav controller
    var optionViewHeightConstraint = NSLayoutConstraint()
    var isOptionMenuOpen: Bool = false
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.collectionView.register(MainScreenCell.self, forCellWithReuseIdentifier: "MainScreenCell")
        optionViewFrame.delegate = self
        
        setupStorageTitleOptionView()
        optionViewFrame.dropDownOptions = ["CloudKit Storage","Local Storage"]
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        photoArray.removeAll()
        getStorageTypeFromMemory() //dataSource from cloud or local mem
    }
    
    func getPhotoData_From(_ type: PHOTO_STORAGE_TYPE){
        switch type {
        case .cloud:
            getCKCollectionFolderInfo()
            break
        case .local:
            getImagesFromCoreData()
            OperationQueue.main.addOperation({ () -> Void in
                self.setFetchedDataToCells()
                self.collectionView.reloadData()
            })
            
            break
        }
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
    
    func getUserDefaultStorageType() -> String{
        return UserDefaults.standard.getDefaultStorageType()
    }
    
    func setUserDefaultStorageType(_ type: String){
        UserDefaults.standard.setDefaultStorageType(value: type)
    }
    
    //MARK: Data Sources
    func getImagesFromCoreData(){
        
        guard let unwrappedPhotoArray = self.coreDataFunctions?.photoArray else {return}
        self.photoArray = unwrappedPhotoArray
        self.setFetchedDataToCells()
    }
    
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
    
    
    //MARK: Cell Setup
    
    func setFetchedDataToCells(){
        //didSelectRow
        self.photoArray.sort{$0.name<$1.name}
        let grid = Grid(columns: 2, margin: UIEdgeInsets(horizontal: 0, vertical: 25), padding: .zero)
        let items = photoArray.map { [weak self] photoArray in
            MainScreenViewModel(photoArray)
                .onSelect { [weak self] viewModel in


                    let date = viewModel.model.date
                    let photo = viewModel.model.image
                    let id = viewModel.model.id
                    let name = viewModel.model.name
                    let photoModel = PhotoCollectionObject(date: date, photo: photo, id: id, name: name, ckrecordID: CKRecord.ID(recordName: "foo"), hideBlurView: true)
                    
                    let collage_Step4_PhotoSelection = Collage_Step4_PhotoSelection(coreDataFunctions: self!.coreDataFunctions!, cloudKitOperations: self!.cloudkitOperations!, photoModel: photoModel, collage_Draw: self!.collage_Draw!)
                    
                    let nameUID = viewModel.model.nameUID
                    collage_Step4_PhotoSelection.collectionNameUID = nameUID
                    self?.show(collage_Step4_PhotoSelection, sender: nil)
            }
        }
        
        let photoSection = Section(grid: grid, header: nil, footer: nil, items: items)
        self.collectionView.source = .init(grid: grid, sections: [photoSection])
        self.collectionView.reloadData()
    }
    
    //MARK: Nav Button Setup
    func setupStorageTitleOptionView(){
        storageOptionView.isUserInteractionEnabled = true
        self.navigationItem.titleView = storageOptionView
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
            if (self.optionViewFrame.tableView.contentSize.height > 150) {
                self.optionViewHeightConstraint.constant = 100
            }
            else {
                self.optionViewHeightConstraint.constant = self.optionViewFrame.tableView.contentSize.height
            }
            
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
}
