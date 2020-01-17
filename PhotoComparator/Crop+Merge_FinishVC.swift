//
//  Crop+Merge_FinishVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/24/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import UIKit
import MessageUI

class Crop_Merge_FinishVC: UIViewController, MFMessageComposeViewControllerDelegate {
    

    var croppedPhotos: Array<PhotoCollectionObject> = []
    var cloudkitOperations = CloudKitFunctions()
    var firstImage = UIImage()
    var secondImage = UIImage()
    var dateString = ""
    var photoDisplayModeActivated = true
    var viewModeString_Opposite: String = "Landscape Mode"
    var viewModeBool_isPortraitModeActive: Bool = false
    
    var earlierDate: NSDate! //dates for each photo
    var laterDate: NSDate!
    var shouldShowDateLabel:Bool = false
    
    enum photoViewMode {
        case landscape
        case portrait
    }
    
    //MARK: Initilization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setDateLabel()

        constructTimelapsePicture(.portrait)
        navigationBarSetup()
        self.navigationController?.navigationBar.isHidden = photoDisplayModeActivated
    }
    
    //MARK: Navigaiton bar setup
    func navigationBarSetup(){
        let exportButton = UIBarButtonItem(title: ionicon.iOSMore.rawValue, style: .plain, target: self, action: #selector(showOptionsButtonPressed))
        let attributes = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(26)] as Dictionary
        exportButton.tintColor = self.view.tintColor
        exportButton.setTitleTextAttributes(attributes, for: .normal)
        exportButton.setTitleTextAttributes(attributes, for: .highlighted)
        
        let backButton = UIBarButtonItem(title: ionicon.ChevronLeft.rawValue + " Exit", style: .plain, target: self, action: #selector(exitCroppedView))
        let attributes2 = [NSAttributedString.Key.font: UIFont.ioniconFontOfSize(18)] as Dictionary
        backButton.tintColor = self.view.tintColor
        backButton.setTitleTextAttributes(attributes2, for: .normal)
        backButton.setTitleTextAttributes(attributes2, for: .highlighted)
        
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = exportButton
    }
    
    @objc func exitCroppedView(){
        let exitNotice = UIAlertController(title: "Are you sure?", message: "By selecting continue, this comparison photo will be lost unless you have already saved it.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Discard", style: .destructive) { handler in
            self.navigationController?.popViewControllers(controllersToPop: 3, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        exitNotice.addAction(continueAction)
        exitNotice.addAction(cancelAction)
        present(exitNotice, animated: true, completion: nil)
    }
    
    //MARK: View Setup
    var imageView: UIImageView = {
        var imageview = UIImageView()
        imageview.backgroundColor = UIColor.black
        imageview.contentMode = .scaleAspectFit
        imageview.clipsToBounds = true
        imageview.isUserInteractionEnabled = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()

    var dateLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //MARK: Date info
    
    func setDateLabel(){

        if (croppedPhotos[0].date < croppedPhotos[1].date){
            earlierDate = croppedPhotos[0].date
            laterDate = croppedPhotos[1].date
            firstImage = self.croppedPhotos[0].photo
            secondImage = self.croppedPhotos[1].photo
        }
        else {
            //left image is older
            earlierDate = croppedPhotos[1].date
            laterDate = croppedPhotos[0].date
            firstImage = self.croppedPhotos[1].photo
            secondImage = self.croppedPhotos[0].photo
        }
        
        dateString = "(\(earlierDate.formatDate()) - \(laterDate.formatDate())) \n\(timeFrom(lhs: earlierDate, rhs: laterDate))"
        dateLabel.text = dateString
        dateLabel.alpha = 0.65
        
        setDateLabelPosition(.middle)
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchDateLabelPosition)))
    }
    
    @objc func switchDateLabelPosition(){
        if (dateLabel.tag == 1){
            setDateLabelPosition(.bottom)
        }
        else if (dateLabel.tag == 2){
            setDateLabelPosition(.top)
        }
        else {
            setDateLabelPosition(.middle)
        }
    }
    
    //MARK: Date label position
    
    enum dateLabelPosition {
        case top
        case middle
        case bottom
    }
    
    func setDateLabelPosition(_ position: dateLabelPosition){
        self.dateLabel.removeFromSuperview()
        self.imageView.addSubview(dateLabel)

        let centerDateLabelConstraint = dateLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        let topDateLabelConstraint = dateLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: 10)
        let bottomDateLabelConstraint = dateLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -10)
        
        dateLabel.frame.size = CGSize(width: dateLabel.intrinsicContentSize.width, height: dateLabel.intrinsicContentSize.height)
        dateLabel.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
        
        
        switch position {
        case .top:
            print("top")
            dateLabel.tag = 0
            NSLayoutConstraint.deactivate([
                centerDateLabelConstraint,
                topDateLabelConstraint,
                bottomDateLabelConstraint])
            NSLayoutConstraint.activate([topDateLabelConstraint])
            
            break
        case .middle:
            print("mid")
            dateLabel.tag = 1
            NSLayoutConstraint.deactivate([
                centerDateLabelConstraint,
                topDateLabelConstraint,
                bottomDateLabelConstraint])
            NSLayoutConstraint.activate([centerDateLabelConstraint])
            break
        case .bottom:
            print("bot")
            dateLabel.tag = 2
            NSLayoutConstraint.deactivate([
                centerDateLabelConstraint,
                topDateLabelConstraint,
                bottomDateLabelConstraint])
            NSLayoutConstraint.activate([bottomDateLabelConstraint])
            break
        }
    }
    
    //MARK: Setting constraints
    func setupViews(){
        self.view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        

        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTappedImageView(_:))))
    }
    
    //MARK: TapGesture
    @objc func userTappedImageView(_ sender: UITapGestureRecognizer){
        print("tapped")
        photoDisplayModeActivated.toggle()
        self.navigationController?.navigationBar.isHidden = photoDisplayModeActivated
    }
    
    //MARK: drawing photo
    func constructTimelapsePicture(_ layout: photoViewMode){
        var height: CGFloat = 0

        
        switch layout {
        case .portrait:
            //photos vertically stacked
            let halfViewFrameHeight = self.view.frame.size.height/2
            let halfViewFrameWidth = self.view.frame.size.width/2
            
            let firstPhotoRatio = firstImage.size.height / firstImage.size.width
            let firstImageWidth = halfViewFrameHeight * firstPhotoRatio
            let halfFirstImageWidth = firstImageWidth/2
            let xPointToCenterImage_1 = halfViewFrameWidth - halfFirstImageWidth
            
            let secondPhotoRatio = firstImage.size.height / firstImage.size.width
            let secondImageWidth = halfViewFrameHeight * secondPhotoRatio
            let halfSecondImageWidth = secondImageWidth/2
            let xPointToCenterImage_2 = halfViewFrameWidth - halfSecondImageWidth
            
            
            let size = CGSize(width: self.view.frame.width, height: self.view.frame.size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            firstImage.draw(in: CGRect(x: xPointToCenterImage_1, y: 0, width: firstImageWidth, height: halfViewFrameHeight))
            secondImage.draw(in: CGRect(x: xPointToCenterImage_2, y: halfViewFrameHeight, width: secondImageWidth, height: halfViewFrameHeight))

            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView.image = newImage
            break
        case .landscape:
            //side by side
            
            let halfViewFrameWidth = self.view.frame.size.width/2
            let halfViewFrameHeight = self.view.frame.size.height/2
            
            let firstPhotoRatio = firstImage.size.height / firstImage.size.width
            let firstImageHeight = halfViewFrameHeight * firstPhotoRatio
            let halfFirstImageHeight = firstImageHeight/2
            let yPointToCenterImage_1 = halfViewFrameHeight - halfFirstImageHeight

            
            let secondPhotoRatio = secondImage.size.height / secondImage.size.width
            let secondImageHeight = halfViewFrameHeight * secondPhotoRatio
            let halfSecondImageHeight = secondImageHeight/2
            let yPointToCenterImage_2 = halfViewFrameHeight - halfSecondImageHeight
            
            if (firstImageHeight > secondImageHeight){
                height = firstImageHeight
            }
            else {
                height = secondImageHeight
            }
            let size = CGSize(width: self.view.frame.width, height: height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            firstImage.draw(in: CGRect(x:0, y:yPointToCenterImage_1-halfFirstImageHeight, width:halfViewFrameWidth, height: firstImageHeight))
            secondImage.draw(in: CGRect(x:halfViewFrameWidth, y:yPointToCenterImage_2-halfSecondImageHeight, width: halfViewFrameWidth,  height: secondImageHeight))
            
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView.image = newImage
            break
        }
    }
    
    
    //MARK: Export options
    
    @objc func showOptionsButtonPressed(){
        let options = UIAlertController(title: "Option", message: "Select the desired options for this photo.", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save to camera roll", style: .default) { handler in
            
            if let imageToSave = self.imageView.image {
                UIImageWriteToSavedPhotosAlbum(imageToSave, self, nil, nil)
            }
            else {
                showSimpleAlertWithTitle("Error", message: "Cannot save image to camera roll.", viewController: self)
            }
        }
        
        let photoViewMode = UIAlertAction(title: viewModeString_Opposite, style: .default) { handler in
            if(self.viewModeBool_isPortraitModeActive){
                //portrait mode deactivated. Set viewModeString_Opposite to say the opposite in order for user to know it has changed
                self.viewModeBool_isPortraitModeActive.toggle()
                self.constructTimelapsePicture(.landscape)
                self.viewModeString_Opposite = "Portrait Mode"
            }
            else{
                //landscape mode deactivated. Set viewModeString_Opposite to say the opposite in order for user to know it has changed
                self.viewModeBool_isPortraitModeActive.toggle()
                self.constructTimelapsePicture(.portrait)
                self.viewModeString_Opposite = "Landscape Mode"
            }
        }
        
        let saveToCollection = UIAlertAction(title: "Save to Collection", style: .default) { handler in
            let collectionSelectorVC = CollectionListVC()
            collectionSelectorVC.cloudkitOperations = self.cloudkitOperations
            collectionSelectorVC.imageToSave = self.imageView.image
            self.navigationController?.pushViewController(collectionSelectorVC, animated: true)
        }

        let toggleDateView = UIAlertAction(title: "Edit Date Label", style: .default) { handler in
            self.shouldShowDateLabel.toggle()
            self.dateLabel.isHidden = self.shouldShowDateLabel
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        options.addAction(saveAction)
        options.addAction(photoViewMode)
        options.addAction(saveToCollection)
        options.addAction(toggleDateView)
        options.addAction(cancelAction)
        present(options, animated: true, completion:nil)
    }


    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
       if error != nil {
        let alert=UIAlertController(title: "Error", message: "Your Cropped Image could not be saved", preferredStyle: UIAlertController.Style.alert);
        show(alert, sender: self);
       }
    }
    
    
    //MARK: Text message didFinish
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("Message Sent!")
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     options:
     save to camera roll
     upload to collection
     new collection?
     share?
     discard
     */
}
