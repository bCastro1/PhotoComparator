//
//  PhotoCollectionViewModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import CloudKit

class PhotoCollectionViewModel: ViewModel<PhotoCollectionCell,PhotoCollectionObject>{
    
    override func updateView() {
        self.view?.dateLabel.text = self.model.date.formatDate()
        self.view?.imageView.image = self.model.photo
        self.view?.trashButton.isHidden = true
        self.view?.blurView.isHidden = self.model.hideBlurView
        
        self.view?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
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

    @objc func longPress(){
        print("long hold")
        self.view?.trashButton.isHidden.toggle()
    }
    
    
    
}
