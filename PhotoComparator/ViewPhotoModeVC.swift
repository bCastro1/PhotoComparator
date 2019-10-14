//
//  ViewPhotoModeVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/7/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import Foundation

class ViewPhotoModeVC: UIViewController, UIScrollViewDelegate {

    var viewPhoto_View = ViewPhoto_View()
    var photoArray: Array<PhotoCollectionObject> = []
    var index: Int = 0
    
    var shouldHideExitButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.viewPhoto_View.delegate = self
        setupPhotoView()
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
        
        viewPhoto_View.imageView.image = photoArray[index].photo
        viewPhoto_View.updateIndex(currentIndex: index, total: photoArray.count)
        
        viewPhoto_View.isUserInteractionEnabled = true
    
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomImageWithPinch))

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        rightSwipe.direction = .right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        leftSwipe.direction = .left
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        upSwipe.direction = .up
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        downSwipe.direction = .down
        
        viewPhoto_View.addGestureRecognizer(pinchGesture)
        viewPhoto_View.addGestureRecognizer(rightSwipe)
        viewPhoto_View.addGestureRecognizer(leftSwipe)
        viewPhoto_View.addGestureRecognizer(upSwipe)
        viewPhoto_View.addGestureRecognizer(downSwipe)

        viewPhoto_View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitToggle)))
        viewPhoto_View.exitButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitPhotoView)))
        
    }
    
    
    //MARK: Actions
    @objc func zoomImageWithPinch(_ gesture : UIPinchGestureRecognizer){
        viewPhoto_View.minimumZoomScale = 1
        viewPhoto_View.maximumZoomScale = 10.0
        
        let scale = (viewPhoto_View.transform.scaledBy(x: gesture.scale, y: gesture.scale))
         guard scale.a > 1.0 else { return }
         guard scale.d > 1.0 else { return }
         viewPhoto_View.transform = scale
         gesture.scale = 1.0
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewPhoto_View.imageView
    }
    
    @objc func swipeAction(_ gestureRecognizer : UISwipeGestureRecognizer){
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

    @objc func exitPhotoView(){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func exitToggle(){
        viewPhoto_View.exitButton.isHidden = (shouldHideExitButton)
        shouldHideExitButton.toggle()
    }
}
