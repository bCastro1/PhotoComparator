//
//  Crop+MergeVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/22/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//  Image cropping functionality by Deb S.
// https://appsbydeb.wordpress.com/2016/07/26/ios-swiftalternative-approach-image-cropuiscrollview-with-pan-and-zoom-enabled/
//

/*
 beore cropping. right bar button has crop + left is back
 after crop pressed. right bar is continue + left is discard
 update image view. crop disabled.
 its fine for now.
 */

import UIKit
import AVKit

class Crop_MergeVC: UIViewController/*, UIScrollViewDelegate*/ {

    
    var photoArray_ObjectsToMerge: Array<PhotoCollectionObject> = [] //passed photos
    var index: Int = 0
    var cropped_ObjectToMerge: Array<PhotoCollectionObject> = [] //edited photos
    var cloudkitOperations = CloudKitFunctions()
    var imagePicked = UIImage()
    
    var _frame: CROP_OPTIONS!
    var cropType: CROP_TYPE!
    
    var imgviewrect: CGRect!
    var hasUserCroppedImage = false
    var cropShape: String = "None"
    
    var continueButton = UIBarButtonItem()
    
    //MARK: Initilization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.cropped_ObjectToMerge.append(self.photoArray_ObjectsToMerge[index])
        imagePicked = photoArray_ObjectsToMerge[index].photo
        setNavigationButtons()
        setupViews()
    }
    
    
    //MARK: Navigation Setup
    func setNavigationButtons(){
//        if (hasUserCroppedImage){
//            let continueButton = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(continueButtonAction))
//            let backButton = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(discardCrop))
//            self.navigationItem.rightBarButtonItem = continueButton
//            self.navigationItem.leftBarButtonItem = backButton
//        }
//        else {
//            let cropButton = UIBarButtonItem(title: "Crop", style: .done, target: self, action: #selector(cropImage))
//            let backButton = UIBarButtonItem(title: ionicon.ChevronLeft.rawValue + "Back", style: .plain, target: self, action: #selector(backButtonAction))
//            let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(18)] as Dictionary
//            backButton.tintColor = self.view.tintColor
//            backButton.setTitleTextAttributes(attributes, for: .normal)
//            backButton.setTitleTextAttributes(attributes, for: .highlighted)
//
//            self.navigationItem.rightBarButtonItem = cropButton
//            self.navigationItem.leftBarButtonItem = backButton
//        }

        
        
        
        self.continueButton = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(continueButtonAction))
        self.navigationItem.rightBarButtonItem = self.continueButton

    }
    
    //MARK: Navigation actions
    
    
    
    
    //MARK: Crop image
    @objc func cropImage(){
        hasUserCroppedImage = true
        retrieveCroppedImage()
        setNavigationButtons()
        self.imageView.image = cropped_ObjectToMerge[index].photo
        cropView.isHidden = true
        cropShapeIndicator.isHidden = true
        
        //setting button for next action
        cropButton.setTitle("Reset Crop", for: .normal)
        cropButton.setTitle("Reset Crop", for: .selected)
        cropButton.addTarget(self, action: #selector(discardCrop), for: .touchUpInside)
    }
    
    @objc func discardCrop(){
        hasUserCroppedImage = false
        setNavigationButtons()
        self.imageView.image = photoArray_ObjectsToMerge[index].photo
        self.cropped_ObjectToMerge[index].photo = photoArray_ObjectsToMerge[index].photo
        cropView.isHidden = false
        cropShapeIndicator.isHidden = false
        
        //setting button for opposite reaction
        cropButton.setTitle("Crop!", for: .normal)
        cropButton.setTitle("Crop!", for: .selected)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
    }
    
    @objc func continueButtonAction(){
        if (index == 0){
            let cropMergeVC = Crop_MergeVC()
            cropMergeVC.photoArray_ObjectsToMerge = self.photoArray_ObjectsToMerge
            cropMergeVC.cropped_ObjectToMerge = self.cropped_ObjectToMerge
            cropMergeVC.index = 1
            cropMergeVC.cloudkitOperations = cloudkitOperations
            self.navigationController?.pushViewController(cropMergeVC, animated: true)
        }
        else {
            let finishedCropVC = Crop_Merge_FinishVC()
            finishedCropVC.croppedPhotos = self.cropped_ObjectToMerge
            finishedCropVC.cloudkitOperations = self.cloudkitOperations
            self.navigationController?.pushViewController(finishedCropVC, animated: true)
        }
    }
    
    @objc func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: View Setup
    
    var imageView: UIImageView = {
        var iV = UIImageView()
        iV.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            iV.backgroundColor = UIColor.dynamicBackgroundColor
        } else {
            iV.backgroundColor = UIColor.gray
        }
        return iV
    }()
    
    var cropView: CropAreaView = {
        let cropView = CropAreaView()
        cropView.translatesAutoresizingMaskIntoConstraints = false
        return cropView
    }()
    
    var cropShapeIndicator: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isUserInteractionEnabled = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var cropButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.backgroundColor = .red
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isUserInteractionEnabled = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Setup view
    func setupViews(){
        self.view.addSubview(imageView)
        self.cropType = CROP_TYPE.square
        imageView.image = imagePicked
        imageView.frame = self.view.frame
        imgviewrect = imageView.bounds
        self.calculateRect()
        self.makeCropAreaVisible()
        self.cropView.isHidden = true //hidden at first since default shape is None.

        self.view.addSubview(cropShapeIndicator)
        cropShapeIndicator.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
        cropShapeIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cropShapeIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cropShapeIndicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        self.cropShapeIndicator.addTarget(self, action: #selector(cropShapeIndicatorButtonPressed), for: .touchUpInside)
        self.cropShapeIndicator.setTitle("Crop Shape: \(cropShape)", for: .normal)
        
        self.view.addSubview(cropButton)
        cropButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        cropButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cropButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cropButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        cropButton.setTitle("Crop!", for: .normal)
        cropButton.setTitle("Crop!", for: .selected)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        self.cropButton.isHidden = true //hidden at first since no crop shape will be selected when first loading.
    }
    

    
    //MARK: Crop helper actions
    func makeCropAreaVisible(){ //making selected crop area
        cropView.removeFromSuperview()
        let min: CGFloat = imgviewrect.size.height > imgviewrect.size.width ? imgviewrect.size.width:imgviewrect.size.height
        let origin = self.view.center
        let width = min*cropType.Muls().x
        let height = min*cropType.Muls().y
        cropView = CropAreaView(origin: origin, width: width, height: height)
        self.cropShapeIndicator.setTitle("Crop Shape: \(cropShape)", for: .normal)
        self.cropShapeIndicator.setTitle("Crop Shape: \(cropShape)", for: .selected)
        self.view.addSubview(cropView)
    }
    
    func calculateRect(){ // getting same value from the image
        imgviewrect = AVMakeRect(aspectRatio: imagePicked.size, insideRect: imageView.bounds)
        
       print (" Image Frame height:\(imgviewrect.size.height) width:\(imgviewrect.size.width) and x,y =( \(imgviewrect.origin.x) ,\(imgviewrect.origin.y) )" )
    }
    
    func retrieveCroppedImage(){
        let yratio: CGFloat = imgviewrect.size.height / imagePicked.size.height
        let xratio: CGFloat = imgviewrect.size.width / imagePicked.size.width
        var cliprect = CGRect(x: _cropOptions.Center.x - _cropOptions.Width/2, y: _cropOptions.Center.y - _cropOptions.Height/2, width: _cropOptions.Width, height: _cropOptions.Height)
       
        cliprect.size.height =  cliprect.size.height / xratio;
        cliprect.size.width =  cliprect.size.width / xratio;
        cliprect.origin.x = cliprect.origin.x / xratio + imgviewrect.origin.x  / xratio
        cliprect.origin.y = cliprect.origin.y / yratio - imgviewrect.origin.y  / xratio

        let imageRef =  imagePicked.cgImage!.cropping(to: cliprect )
        let croppedImg  = UIImage(cgImage: imageRef!, scale:  UIScreen.main.scale, orientation: imagePicked.imageOrientation)
        self.cropped_ObjectToMerge[index].photo = croppedImg
    }
    
    //MARK: Crop shapes
    @objc func cropShapeIndicatorButtonPressed(){
        let cropShapeNotice = UIAlertController(title: "Crop Shape", message: "", preferredStyle: .actionSheet)
        let none = UIAlertAction(title: "None", style: .default) { handler in
            self.cropView.isHidden = true
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = true
            self.cropShape = "None"
            self.cropShapeIndicator.setTitle("Crop Shape: \(self.cropShape)", for: .normal)
            self.cropShapeIndicator.setTitle("Crop Shape: \(self.cropShape)", for: .selected)
        }
        let square = UIAlertAction(title: "Square", style: .default) { handler in
            self.cropView.isHidden = false
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = false
            self.cropType = CROP_TYPE.square
            self.cropShape = "Square"
            self.makeCropAreaVisible()
        }
        let _3x2 = UIAlertAction(title: "Rectangle 3x2", style: .default) { handler in
            self.cropView.isHidden = false
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = false
            self.cropType = CROP_TYPE.rect3x2
            self.cropShape = "Rectangle 3x2"
            self.makeCropAreaVisible()
        }
        let _2x3 = UIAlertAction(title: "Rectangle 2x3", style: .default) { handler in
            self.cropView.isHidden = false
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = false
            self.cropType = CROP_TYPE.rect2x3
            self.cropShape = "Rectangle 2x3"
            self.makeCropAreaVisible()
        }
        let _4x3 = UIAlertAction(title: "Rectangle 4x3", style: .default) { handler in
            self.cropView.isHidden = false
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = false
            self.cropType = CROP_TYPE.rect4x3
            self.cropShape = "Rectangle 4x3"
            self.makeCropAreaVisible()
        }
        let _3x4 = UIAlertAction(title: "Rectangle 3x4", style: .default) { handler in
            self.cropView.isHidden = false
            self.continueButton.isEnabled = true
            self.cropButton.isHidden = false
            self.cropType = CROP_TYPE.rect3x4
            self.cropShape = "Rectangle 3x4"
            self.makeCropAreaVisible()
        }

        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cropShapeNotice.addAction(none)
        cropShapeNotice.addAction(square)
        cropShapeNotice.addAction(_3x2)
        cropShapeNotice.addAction(_2x3)
        cropShapeNotice.addAction(_4x3)
        cropShapeNotice.addAction(_3x4)
        cropShapeNotice.addAction(cancel)
        


        self.present(cropShapeNotice, animated: true, completion: nil)
    }
    
    
}

