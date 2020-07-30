//
//  TransparencySliderView.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 7/16/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class TransparencySliderView: UIView {

    //MARK: Initialization    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
   //MARK: UI Components
    private var infoLabel: UILabel = {
        var label = UILabel()
        label.text = "Transparency of background photo"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var slider: UISlider = {
        var slider = UISlider()
        slider.isUserInteractionEnabled = true
        slider.value = 0.5
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    

    
    private func setupView(){
        self.backgroundColor = .dynamicBackground()
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.dynamicText().cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(infoLabel)
        self.addSubview(slider)
        
        infoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 10).isActive = true
        infoLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        infoLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        slider.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -10).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        slider.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        slider.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
