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
}
