//
//  PhotoImportViewModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/23/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class PhotoImportViewModel: ViewModel<PhotoImportCell, PicturedObject>{
    
    override func updateView() {
        self.view?.dateLabel.text = self.model.date.formatDate()
        self.view?.imageView.image = self.model.photo
    }
    
    override func size(grid: Grid) -> CGSize {
        if (self.collectionView.traitCollection.userInterfaceIdiom == .phone &&
             self.collectionView.traitCollection.verticalSizeClass == .compact) ||
            self.collectionView?.traitCollection.userInterfaceIdiom == .pad
        {
            return grid.size(for: self.collectionView, ratio: 1.2, items: grid.columns / 4, gaps: grid.columns - 1)
        }
        if grid.columns == 1 {
            return grid.size(for: self.collectionView, ratio: 1.1)
        }

        return grid.size(for: self.collectionView, ratio: 1.2, items: grid.columns / 2, gaps: grid.columns - 1)
    }
}
