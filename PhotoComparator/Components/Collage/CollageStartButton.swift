//
//  CollageStartButton.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/31/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class CollageStartButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupButton()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton(){
        self.setTitle("Start", for: .normal)
        self.layer.masksToBounds = true
        self.setTitleColor(.primaryColor(), for: .normal)
        self.backgroundColor = .secondaryColor()
        self.layer.borderColor = UIColor.primaryColor().cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.textColor = .secondaryColor()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
