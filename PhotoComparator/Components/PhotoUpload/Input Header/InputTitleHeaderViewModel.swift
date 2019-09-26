//
//  InputTitleHeaderViewModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/25/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class InputTitleHeaderViewModel: ViewModel<InputTitleHeaderCell, InputTitleHeaderModel> {
    override var height: CGFloat{
        45
    }
    
    override func updateView() {
        guard let text = self.view?.inputHeaderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        self.model.inputtedTitle = text
    }
}
