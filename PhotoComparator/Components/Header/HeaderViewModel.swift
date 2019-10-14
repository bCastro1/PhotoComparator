//
//  HeaderViewModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit


class HeaderViewModel: ViewModel<HeaderCell,HeaderModel>{
    
    override var height: CGFloat {
        64
    }

    override func updateView() {
        self.view?.titleLabel.text = self.model.title
    }

}
