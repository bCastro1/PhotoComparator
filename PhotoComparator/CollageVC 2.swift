//
//  CollageVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class CollageVC: UIViewController {
    
    //MARK:Init
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
    
    var startButton = CollageStartButton()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        setupPage()
        startButton.addTarget(self, action: #selector(startCollageButtonPressed), for: .touchUpInside)
    }
    
    //MARK: ViewWill(Dis)Appear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Collage"
    }

    
    //MARK: Components/setup
    var instructionLabel: UILabel = {
        var label = UILabel()
        label.text = "Info about making a collage goes here :)"
    
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    
    func setupPage(){
        self.view.addSubview(instructionLabel)
        self.view.addSubview(startButton)
        
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        instructionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        instructionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        instructionLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        instructionLabel.bottomAnchor.constraint(equalTo: self.startButton.topAnchor, constant: 10).isActive = true
    }
    
    @objc func startCollageButtonPressed(){
        let collageStep1 = Collage_Step1(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
        collageStep1.hidesBottomBarWhenPushed = true
        collageStep1.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(collageStep1, animated: true)
    }
}
