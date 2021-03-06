//
//  Collage_Step2_Crop.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/3/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import AVKit
import CoreData

class Collage_Step5_Crop: UIViewController {

    
    //crop passed photo, pop back to collage page
    
    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, originalImage: PhotoCollectionObject, collage_Draw: Collage_Draw){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.original_ImageObject = originalImage
        self.imagePicked = self.original_ImageObject!.photo
        self.collage_Draw = collage_Draw        
        let shape = Collage_CropShape(cropShape: self.collage_Draw!.chosenLayout   , index: self.collage_Draw!.layoutIndex)
        self.cropType = shape.returnCropShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Variable declaration
    var collage_Draw: Collage_Draw?
    
    var original_ImageObject: PhotoCollectionObject? //original model
    var cropped_ImageObject: PhotoCollectionObject? //model to edit

    var imagePicked = UIImage() //image to edit
    
    
    var _frame: CROP_OPTIONS!
    var cropType: CROP_TYPE!
    
    var imgviewrect: CGRect!
    var hasUserCroppedImage = false
    var cropShape: String = "None"
    
    var doneButton = UIBarButtonItem()
    var tutorialView = Tutorial_View()

    
    //MARK: Components
    var imageView: UIImageView = {
        var iV = UIImageView()
        iV.contentMode = .scaleAspectFit
        iV.backgroundColor = .dynamicBackground()
        return iV
    }()
    
    var cropView: CropAreaView = {
        let cropView = CropAreaView()
        cropView.translatesAutoresizingMaskIntoConstraints = false
        return cropView
    }()

    
    var cropButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(.primaryColor(), for: .normal)
        button.setTitleColor(.primaryColor(), for: .selected)
        button.backgroundColor = .secondaryColor()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isUserInteractionEnabled = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.primaryColor().cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
    
extension Collage_Step5_Crop {
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.cropped_ImageObject = self.original_ImageObject
        imagePicked = self.original_ImageObject!.photo
        
        self.doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        self.doneButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.doneButton
        setupViews()
        tutorialViewSetup()
    }
    
    
    //MARK: Setup view
    func setupViews(){
        self.view.addSubview(imageView)
        imageView.image = imagePicked
        imageView.frame = self.view.frame
//        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
//        imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        imgviewrect = imageView.bounds
        self.calculateRect()
        self.makeCropAreaVisible()
        
        self.view.addSubview(cropButton)
        cropButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        cropButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cropButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cropButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        cropButton.setTitle("Crop!", for: .normal)
        cropButton.setTitle("Crop!", for: .selected)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
    }

    //MARK: Tutorial View
    func tutorialViewSetup(){
        if (UserDefaults.standard.getTutorialDefault(tutorialType: .collage) == "show"){
            tutorialView = Tutorial_View(frame: self.view.frame, tutorialTextID: .collageCrop)
            tutorialView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tutorialView)
            self.tutorialView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.tutorialView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.tutorialView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tutorialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.view.bringSubviewToFront(tutorialView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTutorialView))
            self.tutorialView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissTutorialView(){
        self.tutorialView.removeFromSuperview()
    }
    
    
    //MARK: (un)Crop image
    @objc func cropImage(){
        hasUserCroppedImage = true
        retrieveCroppedImage()
        self.imageView.image = cropped_ImageObject?.photo
        self.collage_Draw?.collageObjects.append(Collage_Model(index: self.collage_Draw!.layoutIndex, photoWithMetaData: cropped_ImageObject!))
        self.doneButton.isEnabled = true

        cropView.isHidden = true
        
        //setting button for next action
        cropButton.setTitle("Undo", for: .normal)
        cropButton.setTitle("Undo", for: .selected)
        cropButton.addTarget(self, action: #selector(discardCrop), for: .touchUpInside)
    }
    
    @objc func discardCrop(){
        hasUserCroppedImage = false
        self.imageView.image = original_ImageObject?.photo
        self.cropped_ImageObject?.photo = self.original_ImageObject!.photo
        self.doneButton.isEnabled = false

        cropView.isHidden = false

        //setting button for opposite reaction
        cropButton.setTitle("Crop", for: .normal)
        cropButton.setTitle("Crop", for: .selected)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
    }
    
    
    //MARK: Crop helper actions
    func makeCropAreaVisible(){ //making selected crop area
        cropView.removeFromSuperview()
        let min: CGFloat = imgviewrect.size.height > imgviewrect.size.width ? imgviewrect.size.width:imgviewrect.size.height
        let origin = self.view.center
        let width = min*cropType.Muls().x
        let height = min*cropType.Muls().y
        cropView = CropAreaView(origin: origin, width: width, height: height)
        self.view.addSubview(cropView)
    }
    
    func calculateRect(){ // getting same value from the image
        imgviewrect = AVMakeRect(aspectRatio: imagePicked.size, insideRect: imageView.bounds)
        
//        print("imagePicked.size: \(imagePicked.size)")
//        print("iv bounds \(imageView.bounds)")
//        print("imgv rect \(imgviewrect)")
//        print(" ")
        print("stk: \(getImageFrameInImageView(imageView: imageView))")
        print(" ")
        
        
        /*
         normal op: imgView height larger than actual image
         
         scuffed: imgView height ratio turns out to be same 
         */
    }
    
    func getImageFrameInImageView(imageView : UIImageView) -> CGRect {

        let image = imageView.image!
        let wi = image.size.width
        let hi = image.size.height
        print("wi:\(wi), hi:\(hi)")

        let wv = imageView.frame.width
        let hv = imageView.frame.height
        print("wv:\(wv), hv:\(hv)")

        let ri = hi / wi
        let rv = hv / wv
        print("ri:\(ri), rv:\(rv)")

        var x, y, w, h: CGFloat

        if ri > rv {
            h = hv
            w = h / ri
            x = (wv / 2) - (w / 2)
            y = 0
        } else {
            w = wv
            h = w * ri
            x = 0
            y = (hv / 2) - (h / 2)
        }

        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func retrieveCroppedImage(){
//        print("imgViewRect width: \(imgviewrect.size.width)")
//        print("imgViewRect height: \(imgviewrect.size.height)")
//        print("imagePicked width: \(imagePicked.size.width)")
//        print("imagePicked height: \(imagePicked.size.height)")

        let yratio: CGFloat = imgviewrect.size.height / imagePicked.size.height
        let xratio: CGFloat = imgviewrect.size.width / imagePicked.size.width
//        print("y: \(yratio)")
//        print("x: \(xratio)")
        
        var cliprect = CGRect(x: _cropOptions.Center.x - _cropOptions.Width/2, y: _cropOptions.Center.y - _cropOptions.Height/2, width: _cropOptions.Width, height: _cropOptions.Height)
        
//        print("clipRect: \(cliprect)")
//        print("imgViewRect: \(imgviewrect ?? CGRect(x: 0, y: 0, width: 0, height: 0))")
        
        cliprect.size.height =  cliprect.size.height / xratio;
        cliprect.size.width =  cliprect.size.width / xratio;
        cliprect.origin.x = cliprect.origin.x / xratio + imgviewrect.origin.x  / xratio
        cliprect.origin.y = cliprect.origin.y / yratio - imgviewrect.origin.y  / yratio //last num was x ratio

        let imageRef =  imagePicked.cgImage!.cropping(to: cliprect )
        let croppedImg  = UIImage(cgImage: imageRef!, scale:  UIScreen.main.scale, orientation: imagePicked.imageOrientation)
        cropped_ImageObject?.photo = croppedImg
        
//        print("2clip rect: \(cliprect)")
//        print("cr height: \(cliprect.size.height)")
//        print("cr width: \(cliprect.size.width)")
//        print("cr x origin: \(cliprect.origin.x)")
//        print("cr y origin: \(cliprect.origin.y)")
//        print(" ")
    }
    
    @objc func doneButtonTapped(){
        let addToCollage = Collage_Step2(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!, collage_Draw: self.collage_Draw!)
        addToCollage.modalPresentationStyle = .fullScreen
        
        
        let nav = self.navigationController
        DispatchQueue.main.async {
            nav?.view.layer.add(CATransition().pushFromLeft(), forKey: nil)
            nav?.pushViewController(addToCollage, animated: false)
        }
    }
}
