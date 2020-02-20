//
//  HeaderCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class HeaderCell: Cell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        self.titleLabel.textColor = .dynamicText()
    }
    
    override func reset() {
        super.reset()
        self.titleLabel.text = nil
    }
    
}
