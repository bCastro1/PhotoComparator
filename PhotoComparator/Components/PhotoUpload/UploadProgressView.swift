//
//  UploadProgressView.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 11/18/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit

class UploadProgressView: UIView {

    //MARK: Initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: View setup
    func setupView(){
        self.progressView.progressViewStyle = .bar
        self.translatesAutoresizingMaskIntoConstraints = true
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        
        self.addSubview(progressView)
        self.addSubview(progressLabel)
        
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        progressView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        progressLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        progressLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: 5).isActive = true
        progressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }
    
    //MARK: Component setup
    
    var progressView: UIProgressView = {
        let progView = UIProgressView()
        progView.translatesAutoresizingMaskIntoConstraints = false
        return progView
    }()
    
    var progressLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Progress functionality
    func progress(currentIdx: Int, total: Int){
        progressLabel.text = "Saving \(currentIdx) of \(total)"
        progressView.progress = Float(currentIdx) / Float(total)
        
        
    }
}
