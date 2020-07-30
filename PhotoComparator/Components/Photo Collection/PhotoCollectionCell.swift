//
//  PhotoCollectionCell.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit


class PhotoCollectionCell: Cell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.dateLabel.textColor = .dynamicText()
        self.imageView.backgroundColor = .dynamicBackground()
        self.imageView.layer.cornerRadius = 5
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.trashButton.setImage(UIImage.imageWithIonicon(.iOSTrash, color: .defaultTint, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        
        blurView.alpha = 0.5
        blurView.backgroundColor = UIColor.white
    }
    
    override func reset(){
        super.reset()
        blurView.isHidden = true
        self.imageView.image = nil
        self.dateLabel.text = nil
    }
}
