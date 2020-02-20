//
//  CollageSection_SelectButton.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/3/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class CollageSection_SelectButton: UIButton {

    var imageHasBeenSet: Bool = false
    var layoutSelected: String = ""
    
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
        self.imageHasBeenSet = false
        self.backgroundColor = .clear
        self.setTitleColor(.red, for: .normal)
        self.titleLabel?.font = UIFont(name: "Arial", size: 72)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

}
