//
//  ExploreViewModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 3/26/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class ExploreViewModel: ViewModel<ExploreCell, ExploreModel> {
    
    override func updateView() {
        self.view?.ratingLabel.text = String(self.model.rating)
        self.view?.dateLabel.text = self.model.date.formatDate_DayMonth()
        self.view?.imageView.image = self.model.image
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
        else if grid.columns == 3 {
            //makes text label disappear ...?
            return grid.size(for: self.collectionView, ratio: 1.0)
        }
        else if grid.columns == 4 {
            //makes text label disappear ...?
            return grid.size(for: self.collectionView, ratio: 0.9)
        }
        return grid.size(for: self.collectionView, ratio: 1.2, items: grid.columns / 2, gaps: grid.columns - 1)
    }
}
