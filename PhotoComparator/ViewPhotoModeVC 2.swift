//
//  ViewPhotoModeVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/7/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation
import ImageScrollView

class ViewPhotoModeVC: UIViewController, UIGestureRecognizerDelegate  {
    

    var viewPhoto_View = ViewPhoto_View()
    var photoArray: Array<PhotoCollectionObject> = []
    var index: Int = 0
    var isZooming = false
    var originalImageCenter:CGPoint?
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    var photoCollectionVC: PhotoCollectionVC?
    
    var shouldHideExitButton = false
    var shouldHideIndexLabel = false
    
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, photoCollectionVC: PhotoCollectionVC){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.photoCollectionVC = photoCollectionVC
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        setupPhotoView()
        viewPhoto_View.imageView.image = photoArray[index].photo
        viewPhoto_View.exitButton.isHidden = shouldHideExitButton
    }
    
    //MARK: View Setup
    
    func setupPhotoView(){
        //Gestures:
        //Left/Right swipe -> next/previous photo
        //up/down swipe -> exit photo view
        //tap gesture -> reveal/hide exit button
        //pinch gesture -> zoom
        viewPhoto_View = ViewPhoto_View(frame: self.view.bounds)
        self.view.addSubview(viewPhoto_View)
        self.viewPhoto_View.layoutIfNeeded()
        viewPhoto_View.delegate = photoCollectionVC
        viewPhoto_View.updateIndex(currentIndex: index, total: photoArray.count)
        viewPhoto_View.isUserInteractionEnabled = true
    

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        rightSwipe.direction = .right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        leftSwipe.direction = .left
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        upSwipe.direction = .up
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        downSwipe.direction = .down

        viewPhoto_View.imageView.enableZoom()
        //MARK: zoom
        
        viewPhoto_View.addGestureRecognizer(rightSwipe)
        viewPhoto_View.addGestureRecognizer(leftSwipe)
        viewPhoto_View.addGestureRecognizer(upSwipe)
        viewPhoto_View.addGestureRecognizer(downSwipe)
        

        viewPhoto_View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitToggle)))
        viewPhoto_View.exitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitPhotoView)))
        viewPhoto_View.cameraButton.addTarget(self, action: #selector(takeProgressPictureAction), for: .touchUpInside)
    }

    //MARK: UDLR gestures
    @objc func swipeAction(_ gestureRecognizer : UISwipeGestureRecognizer){
        if !(isZooming){
            if (gestureRecognizer.direction == .down){
                self.dismiss(animated: false, completion: nil)
            }
            else if(gestureRecognizer.direction == .up){
                self.dismiss(animated: false, completion: nil)
            }
            else if(gestureRecognizer.direction == .right){
                if (index > 0){
                    viewPhoto_View.reset()
                    index -= 1
                    viewPhoto_View.imageView.image = photoArray[index].photo
                    viewPhoto_View.updateIndex(currentIndex: index, total: photoArray.count)
                }
            }
            else if(gestureRecognizer.direction == .left){
                if(index < photoArray.count-1){
                    viewPhoto_View.reset()
                    index += 1
                    viewPhoto_View.imageView.image = photoArray[index].photo
                    viewPhoto_View.updateIndex(currentIndex: index, total: photoArray.count)
                }
            }
        }
    }
    
    //MARK: Pan gesture
    
    @objc func panImage(_ gesture : UIPanGestureRecognizer){
        if self.isZooming && gesture.state == .began {
            self.originalImageCenter = gesture.view?.center
        }
        else if self.isZooming && gesture.state == .changed {
            let translation = gesture.translation(in: ViewPhoto_View())
            if let view = gesture.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            gesture.setTranslation(CGPoint.zero, in: self.viewPhoto_View.scrollView.superview)
        }
    }


    @objc(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func exitPhotoView(){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func exitToggle(){
        shouldHideExitButton.toggle()
        viewPhoto_View.exitButton.isHidden = shouldHideExitButton
        shouldHideIndexLabel.toggle()
        viewPhoto_View.indexLabel.isHidden = shouldHideIndexLabel
    }
    
    @objc func takeProgressPictureAction(){
        self.dismiss(animated: false, completion: nil)
    }
}

