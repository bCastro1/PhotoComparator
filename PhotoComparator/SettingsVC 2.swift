//
//  AccountVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

// On the docket to be implemented. Going to have a social media aspect with this account info page to

import UIKit

class SettingsVC: UIViewController {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.setupComponents()
    }
    
    //MARK: ViewWill(Dis)Appear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Settings"
    }
    
    private let versionNumberLabel: UILabel = {
        let label = UILabel()
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        if let version = nsObject as? String {
            label.text = "App Version: \(version)"
        }
        label.textColor = .dynamicText()
        label.font = UIFont(name: "Arial", size: 16)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func setupComponents(){
        self.view.addSubview(versionNumberLabel)
        versionNumberLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        versionNumberLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: -15).isActive = true
        versionNumberLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 15).isActive = true
        versionNumberLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
