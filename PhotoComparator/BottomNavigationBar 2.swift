//
//  BottomNavigationBar.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/29/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import CoreData

class BottomNavigationBar: UITabBarController, UITabBarControllerDelegate {

    static let sharedManager = BottomNavigationBar()
    private init(){ super.init(nibName: nil, bundle: nil) }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cloudkitOperations = CloudKitFunctions()
    var coreDataFunctions = CoreDataFunctions(context: CoreDataManager.sharedManager.persistentContainer.viewContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: my albums
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        let collectionsVC = MainCollectionsVC(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
        collectionsVC.cloudkitOperations = self.cloudkitOperations
        
        let collectionsNC = UINavigationController(rootViewController: collectionsVC)
        collectionsNC.title = "Albums"
        collectionsNC.tabBarItem.image = UIImage.imageWithIonicon(.Images, color: .secondaryColor(), iconSize: 35, imageSize: CGSize(width: 35, height: 35))
        
        //MARK: import
//        let importVC = PhotoImportVC(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
//        importVC.photoUploadOperations(operation: .newCollection, uid: nil)
//
//        let importNC = UINavigationController(rootViewController: importVC)
//        importNC.title = "Import"
//        importNC.tabBarItem.image = UIImage.imageWithIonicon(.PlusCircled, color: .secondaryColor(), iconSize: 35, imageSize: CGSize(width: 35, height: 35))
        
        //MARK: collage
        let collageVC = CollageVC(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
        let collageNC = UINavigationController(rootViewController: collageVC)
        collageNC.title = "Collage"
        collageNC.tabBarItem.image = UIImage.imageWithIonicon(.AndroidColorPalette, color: .secondaryColor(), iconSize: 35, imageSize: CGSize(width: 35, height: 35))
        
        
        //MARK: Index
        let cameraVC = Index(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
        let cameraNC = UINavigationController(rootViewController: cameraVC)
        cameraNC.title = "Camera"
        cameraNC.tabBarItem.image = UIImage.imageWithIonicon(.Camera, color: .secondaryColor(), iconSize: 40, imageSize: CGSize(width: 40, height: 40))
        
        
        
        
    /*
         //MARK: explore
         let exploreVC = ExploreVC(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
         
         let exploreNC = UINavigationController(rootViewController: exploreVC)
         exploreNC.title = "Explore"
         exploreNC.tabBarItem.image = UIImage.imageWithIonicon(.Leaf, color: .secondaryColor(), iconSize: 40, imageSize: CGSize(width: 40, height: 40))
       */
        
        //MARK: my account
        let settingsVC = SettingsVC(coreDataFunctions: coreDataFunctions, cloudKitOperations: self.cloudkitOperations)
        let settingsNC = UINavigationController(rootViewController: settingsVC)
        settingsNC.title = "Settings"
        settingsNC.tabBarItem.image = UIImage.imageWithIonicon(.iOSGear, color: .secondaryColor(), iconSize: 35, imageSize: CGSize(width: 35, height: 35))
        
        //MARK: setting tab bar items
        let tabBarList = [collectionsNC, collageNC, cameraNC, settingsNC]
        
        
//        let tabBarList = [collectionsNC, importNC, collageNC, indexNC]
        viewControllers = tabBarList
        tabBar.isTranslucent = false
        
        
        //Dismiss all view controllers except the presented one.
        var controller = presentingViewController
        while let presentingVC = controller?.presentingViewController {
            controller = presentingVC
        }
        controller?.dismiss(animated: true)
    }
    
    
}


/*
 Features:
 
 -Albums page (NOT COLLECTIONS)
    -photo display inside of collection
        -settings....
            -import more, change collection name, delete
    -import page - just add a + in top right of albums page..?
 
 
 -collage page
    -have language to explain process of clicking on sections of collage to change photo
    -final page:
        -add Done to top right...?
        
 
 */
