//
//  ViewPhoto_View.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/7/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class ViewPhoto_View: UIScrollView {
    
    //MARK: Initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.addSubview(imageView)
        self.addSubview(exitButton)
        self.addSubview(indexLabel)
        
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        exitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        exitButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        
        indexLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        indexLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        indexLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        indexLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true

        self.bringSubviewToFront(exitButton)
    }
    
    //MARK: View functionality
    
    func reset(){
        self.imageView.image = nil
        self.indexLabel.text = ""
    }
    
    func updateIndex(currentIndex: Int, total: Int){
        indexLabel.text = "(\(currentIndex+1)/\(total))"
    }
    
    //MARK: Component Setup
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var exitButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSCloseOutline, color: UIColor.black, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var indexLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: "Arial", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
