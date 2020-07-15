//
//  Collage_Finish.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/9/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class Collage_Finish: UIViewController {

    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    var finishedCollage: Collage_Draw?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, finishedCollage: Collage_Draw){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.finishedCollage = finishedCollage
        self.collageImageView.image = self.finishedCollage?.finalCollage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        setupView()
        navigationSetup()
    }

    
    //MARK: Components
    var collageImageView: UIImageView = {
        var imageview = UIImageView()
        imageview.backgroundColor = .white
        imageview.contentMode = .scaleToFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    //MARK: View Setup
    func setupView(){
        self.view.addSubview(collageImageView)
        let screenWidth = self.view.frame.width
        collageImageView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageImageView.heightAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collageImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    //MARK: Navigation Setup
    func navigationSetup(){
        let exportButton = UIBarButtonItem(title: ionicon.iOSMore.rawValue, style: .plain, target: self, action: #selector(showOptionsButtonPressed))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        exportButton.tintColor = self.view.tintColor
        exportButton.setTitleTextAttributes(attributes, for: .normal)
        exportButton.setTitleTextAttributes(attributes, for: .highlighted)
        self.navigationItem.rightBarButtonItem = exportButton
    }
    
    //MARK: Export options
    @objc func showOptionsButtonPressed(){
        UserDefaults.standard.setTutorialDefault(value: "hide", tutorialType: .collage)
        let options = UIAlertController(title: "Option", message: "Select the desired options for this photo.", preferredStyle: .actionSheet)

        let saveToCameraRoll = UIAlertAction(title: "Save to camera roll", style: .default) { handler in

            if let imageToSave = self.collageImageView.image {
                UIImageWriteToSavedPhotosAlbum(imageToSave, self, nil, nil)
                showSimpleAlertWithTitle("Success", message: "Your photo was successfully saved.", viewController: self)
            }
            else {
                showSimpleAlertWithTitle("Error", message: "Cannot save image to camera roll.", viewController: self)
            }
        }

        let saveToCollection = UIAlertAction(title: "Save to an Album", style: .default) { handler in
            let collectionSelectorVC = CollectionListVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
            collectionSelectorVC.imageToSave = self.collageImageView.image
            self.navigationController?.pushViewController(collectionSelectorVC, animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        options.addAction(saveToCameraRoll)
        options.addAction(saveToCollection)
        options.addAction(cancelAction)
        present(options, animated: true, completion:nil)
    }
    
}

