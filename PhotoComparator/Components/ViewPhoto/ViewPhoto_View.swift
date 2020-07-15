//
//  ViewPhoto_View.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/7/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

protocol PhotoComparisonProtocol {
    var photoComparisonIndex: Int { get set }
    var shouldComparePhotos: Bool { get set }
}

class ViewPhoto_View: UIView {

    var delegate: PhotoComparisonProtocol!
    
    //MARK: Initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        setupView()
    }
    
    init(frame: CGRect, delegate: PhotoCollectionVC) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.delegate = delegate
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.addSubview(exitButton)
        self.addSubview(indexLabel)
        self.addSubview(scrollView)
        self.addSubview(cameraButton)
        scrollView.addSubview(imageView)

        exitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        exitButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true

        indexLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indexLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        indexLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 50).isActive = true
        indexLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true

        cameraButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: self.frame.width-50).isActive = true
        cameraButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.indexLabel.bottomAnchor, constant: 12).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true


        imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
   
        self.bringSubviewToFront(indexLabel)
        self.bringSubviewToFront(exitButton)
        self.bringSubviewToFront(cameraButton)
    }
    
    //MARK: View functionality
    
    func reset(){
        self.imageView.image = nil
        self.indexLabel.text = ""
    }
    
    func updateIndex(currentIndex: Int, total: Int){
        indexLabel.text = "(\(currentIndex+1)/\(total))"
        delegate.photoComparisonIndex = currentIndex
    }
    
    //MARK: Component Setup
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var exitButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage.imageWithIonicon(.iOSCloseOutline, color: UIColor.white, iconSize: 40, imageSize: CGSize(width: 40, height: 40)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var indexLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "Arial", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var cameraButton: UIButton = {
        var button = UIButton()
        button.setTitle("Take Progress Picture", for:   .normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.dynamicText(), for: .normal)
        button.layer.backgroundColor = UIColor.primaryColor().cgColor
        button.layer.borderColor = UIColor.secondaryColor().cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(setComparisonPhotoDetails), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func setComparisonPhotoDetails(){
        delegate.shouldComparePhotos = true
    }
}
