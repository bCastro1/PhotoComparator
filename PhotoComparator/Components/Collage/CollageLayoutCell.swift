//
//  CollageLayoutCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/31/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation

class CollageLayoutCell: Cell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel.textColor = .dynamicText()
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
    }
    
    override func reset() {
        super.reset()
        self.imageView.image = nil
        self.textLabel.text = nil
    }

}
