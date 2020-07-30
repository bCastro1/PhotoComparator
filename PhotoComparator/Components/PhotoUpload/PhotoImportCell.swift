//
//  PhotoImportCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/23/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class PhotoImportCell: Cell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.dateLabel.textColor = .dynamicText()
        
        self.imageView.backgroundColor = .dynamicBackground()
        self.imageView.layer.cornerRadius = 5
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFit
    }
    
    override func reset(){
        super.reset()
        self.imageView.image = nil
        self.dateLabel.text = nil
    }
}
