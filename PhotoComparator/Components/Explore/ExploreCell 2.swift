//
//  ExploreCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 3/26/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class ExploreCell: Cell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel.textColor = .dynamicText()
        self.ratingLabel.textColor = .dynamicText()
        self.imageView.backgroundColor = UIColor.gray
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.dateLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    override func reset(){
        self.imageView.image = nil
        self.ratingLabel.text = nil
        self.dateLabel.text = nil
    }
}
