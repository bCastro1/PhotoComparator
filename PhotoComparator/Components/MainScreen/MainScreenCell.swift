//
//  MainScreenCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/21/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class MainScreenCell: Cell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel.textColor = .dynamicText()
        self.imageView.backgroundColor = .dynamicBackground()
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
        
        self.imageView.contentMode = .scaleAspectFill
    }
    
    override func reset() {
        super.reset()
        self.imageView.image = nil
        self.textLabel.text = nil
    }
}
