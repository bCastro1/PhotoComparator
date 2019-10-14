//
//  CompareButton.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/8/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class CompareButton: UIButton {

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
        self.setTitle("Compare Photos", for: .normal)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.blue
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.textColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
