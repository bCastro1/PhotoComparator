//
//  Tutorial View.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 7/6/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit

class Tutorial_View: UIView {
    
    //MARK: Initialization
    init(frame: CGRect, tutorialTextID: TutorialDefaults){
        super.init(frame: frame)
        setGeneralLayout()
        setTutorialViewLayout(tutorialSelected: tutorialTextID)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Enum for tutorials in Extensions.swift
    enum TutorialDefaults {
        case addAlbum //first screen
        case addPhotoToAlbum //import screen first time
        case collageStart
        case collageCrop
        case cameraFollowUp
    }
    
    //MARK: UI Components
    private var alphaBackground: UIView = {
        var view = UIView()
        view.alpha = 0.6
        view.backgroundColor = .dynamicText()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var clearForeground: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var staticInfoTextView: UITextView = {
        var tv = UITextView()
        tv.textAlignment = .center
        tv.textColor = .dynamicBackground()
        tv.font = UIFont.systemFont(ofSize: 26)
        tv.backgroundColor = .clear
        tv.text = "Tap anywhere to dismiss this screen."
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var dynamicinfoTextView: UITextView = {
        var tv = UITextView()
        tv.textAlignment = .center
        tv.textColor = .dynamicBackground()
        tv.font = UIFont.systemFont(ofSize: 22)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var dynamicinfoTextView2: UITextView = {
        var tv = UITextView()
        tv.textAlignment = .center
        tv.textColor = .dynamicBackground()
        tv.font = UIFont.systemFont(ofSize: 22)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var arrowLabel_UP: UILabel = {
        var label = UILabel.labelWithIonicon(.ArrowUpA, color: .red, iconSize: 55)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var arrowLabel_DOWN: UILabel = {
        var label = UILabel.labelWithIonicon(.ArrowDownA, color: .red, iconSize: 55)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

extension Tutorial_View {
    
    //MARK: dynamic layout
    private func setTutorialViewLayout(tutorialSelected: TutorialDefaults){
        self.addSubview(dynamicinfoTextView)
        dynamicinfoTextView.widthAnchor.constraint(equalToConstant: self.frame.width*0.5).isActive = true //half of frame width
        dynamicinfoTextView.heightAnchor.constraint(equalToConstant: self.frame.width*0.5).isActive = true //box - same as height
        

        
        switch tutorialSelected {
        case .addAlbum:
            setupAndAnimateArrow(tutorialSelected: .addAlbum)
            
            dynamicinfoTextView.text = "Tap here to add an album."
            dynamicinfoTextView.topAnchor.constraint(equalTo: self.arrowLabel_UP.bottomAnchor, constant: 10).isActive = true
            dynamicinfoTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
            break
        case .addPhotoToAlbum:
            dynamicinfoTextView.text = "Select photos or take pictures to add to your new album. Copies of the photos will be stored in this app."
            
            dynamicinfoTextView.bottomAnchor.constraint(equalTo: self.staticInfoTextView.topAnchor, constant: 20).isActive = true
            dynamicinfoTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            break
        case .collageStart:
            dynamicinfoTextView.text = "Tap the numbers and select a photo you would like in its place"
            dynamicinfoTextView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            dynamicinfoTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
            break
        case .collageCrop:
            dynamicinfoTextView.text = "Crop the photo to fit the space of the collage. This will not affect the original photo"
            dynamicinfoTextView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            dynamicinfoTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            break
            
        case .cameraFollowUp:
            setupAndAnimateArrow(tutorialSelected: .cameraFollowUp)
            dynamicinfoTextView.text = "Exit or retake a photo"
            dynamicinfoTextView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            dynamicinfoTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 25).isActive = true
            
            self.addSubview(dynamicinfoTextView2)
            dynamicinfoTextView2.text = "Save this photo to an album in this app, or save it to your phone."
            dynamicinfoTextView2.widthAnchor.constraint(equalToConstant: self.frame.width*0.5).isActive = true //half of frame width
            dynamicinfoTextView2.heightAnchor.constraint(equalToConstant: self.frame.width*0.5).isActive = true //box - same as height
            dynamicinfoTextView2.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            dynamicinfoTextView2.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
            break
        }
        
        self.bringSubviewToFront(clearForeground)
    }
    
    //MARK: static General layout
    private func setGeneralLayout(){
        self.addSubview(alphaBackground)
        alphaBackground.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        alphaBackground.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        alphaBackground.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        alphaBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(staticInfoTextView)
        staticInfoTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        staticInfoTextView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        staticInfoTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        staticInfoTextView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(clearForeground)
        clearForeground.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        clearForeground.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        clearForeground.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        clearForeground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    private func setupAndAnimateArrow(tutorialSelected: TutorialDefaults){
        
        switch tutorialSelected {
            
        case .addAlbum:
            self.addSubview(arrowLabel_UP)
            arrowLabel_UP.widthAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_UP.heightAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_UP.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            arrowLabel_UP.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            
        case .addPhotoToAlbum:
            break
        case .collageStart:
            break
        case .collageCrop:
            break
        case .cameraFollowUp:
            self.addSubview(arrowLabel_UP)
            arrowLabel_UP.widthAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_UP.heightAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_UP.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
            arrowLabel_UP.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
            
            self.addSubview(arrowLabel_DOWN)
            arrowLabel_DOWN.widthAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_DOWN.heightAnchor.constraint(equalToConstant: 55).isActive = true
            arrowLabel_DOWN.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            arrowLabel_DOWN.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40).isActive = true
        }

        //pulsate. big/small every other second
        UIView.animate(withDuration: 0.75, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.arrowLabel_UP.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.arrowLabel_DOWN.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.75) {
                self.arrowLabel_UP.transform = CGAffineTransform.identity
                self.arrowLabel_DOWN.transform = CGAffineTransform.identity
            }
        }
    }
}
