//
//  InputTitleHeaderCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/25/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class InputTitleHeaderCell: Cell {
    
    @IBOutlet weak var inputHeaderTextField: UITextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.inputHeaderTextField.placeholder = "New Collection Title"
        self.inputHeaderTextField.textColor = .black
    }
    
    override func reset() {
        super.reset()
        self.inputHeaderTextField.text = nil
    }
}
