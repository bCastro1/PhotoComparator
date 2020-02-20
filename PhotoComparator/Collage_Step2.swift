//
//  Collage_Step2.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/31/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Collage_Step2: UIViewController, Collage_Draw_Protocol, GADInterstitialDelegate {

    

    //MARK:Init
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    var collage_Draw: Collage_Draw?
    
    //new collage start
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, layoutModel: CollageLayoutModel){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        self.title = layoutModel.name
        self.setLayoutImageAndButtonConstraints(layout: Collage_Step2.CollageLayout(rawValue: layoutModel.image)!)
        
        let layout = layoutModel.image //which image model chosen; eg. 2a -> is two horizontal photos side by side
        
        self.collage_Draw = Collage_Draw(frameWidth: self.view.frame.width, frameHeight: self.view.frame.height, layout: layout)
    }

    //used when constructing a collage
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions, collage_Draw: Collage_Draw){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
        
        self.collage_Draw = collage_Draw
        let layout = Collage_Step2.CollageLayout(rawValue: collage_Draw.chosenLayout)!
        self.setLayoutImageAndButtonConstraints(layout: layout)
        self.collageImageView.image = collage_Draw.getCurrentCollageImage()
        self.collageImageView.isHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(discardCollage))
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Variable declaration
    var interstitial: GADInterstitial!
    let googleAdvertAppID = "ca-app-pub-3940256099942544/4411468910" //test ad

    
    
    var layoutSelected: CollageLayout?
    var screenWidth: CGFloat = 0
    
    var invisButton1 = CollageSection_SelectButton()
    var invisButton2 = CollageSection_SelectButton()
    var invisButton3 = CollageSection_SelectButton()
    var invisButton4 = CollageSection_SelectButton()

    enum CollageLayout: String {
        case _2a = "2a"
        case _2b = "2b"
        case _3a = "3a"
        case _3b = "3b"
        case _3c = "3c"
        case _3d = "3d"
        case _4a = "4a"
        case _4b = "4b"
        case _4c = "4c"
        case _4d = "4d"
    }
    
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        setupCollageLayoutView()
        self.interstitial = setupAndReturnAdvert()
        interstitial.delegate = self
        self.collage_Draw?.delegate = self
    }

    
    //MARK: Components
    var collageLayoutImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var collageImageView: UIImageView = {
        var imageview = UIImageView()
        imageview.backgroundColor = .white
        imageview.contentMode = .scaleToFill
        imageview.alpha = 0.5
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()

    
    //MARK: setup funcs
    func setupCollageLayoutView(){
        self.view.addSubview(collageLayoutImageView)
        self.screenWidth = self.view.frame.width
        collageLayoutImageView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageLayoutImageView.heightAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageLayoutImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collageLayoutImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        self.view.addSubview(collageImageView)
        collageImageView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageImageView.heightAnchor.constraint(equalToConstant: screenWidth).isActive = true
        collageImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collageImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.view.bringSubviewToFront(collageImageView)
        collageImageView.isHidden = true
    }
    
    //MARK: Button protocol stubs
    
    func disableButtonWithIndex(_ index: Int) {
        switch index {
        case 0:
            invisButton1.isEnabled = false
            invisButton1.setTitleColor(.white, for: .normal)
        case 1:
            invisButton2.isEnabled = false
            invisButton2.setTitleColor(.white, for: .normal)
        case 2:
            invisButton3.isEnabled = false
            invisButton3.setTitleColor(.white, for: .normal)
        case 3:
            invisButton4.isEnabled = false
            invisButton4.setTitleColor(.white, for: .normal)
        default:
            break
        }
    }
    
    //MARK: Finished Collage Actions
    func collageFinishCheck(_ areTilesFilled: Bool) {
        if (areTilesFilled){
            let finishCollageButton = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(finishCollageButtonAction))
            self.navigationItem.rightBarButtonItem = finishCollageButton
        }
    }
    
    @objc func finishCollageButtonAction(){
        if interstitial.isReady {
          interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
        }
        
        let collageFinishVC = Collage_Finish(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!, finishedCollage: collage_Draw!)
        collageFinishVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(collageFinishVC, animated: true)
    }
    
    //MARK: Push to step3
    @objc func setIndex_PushNextStep(_ sender: CollageSection_SelectButton){
        collage_Draw?.layoutIndex = sender.tag
        let collectionSelection = Collage_Step3_CollectionSelection(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!, collage_Draw: self.collage_Draw!)
        collectionSelection.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(collectionSelection, animated: true)
    }

    //MARK: Discard image
    @objc private func discardCollage(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    //MARK: collage layout button constraints
    func setLayoutImageAndButtonConstraints(layout: CollageLayout){
        invisButton1.tag = 0
        invisButton2.tag = 1
        invisButton3.tag = 2
        invisButton4.tag = 3
        
        self.invisButton1.setTitle("1", for: .normal)
        self.invisButton2.setTitle("2", for: .normal)
        self.invisButton3.setTitle("3", for: .normal)
        self.invisButton4.setTitle("4", for: .normal)

        
        invisButton1.addTarget(self, action: #selector(setIndex_PushNextStep(_:)), for: .touchUpInside)
        invisButton2.addTarget(self, action: #selector(setIndex_PushNextStep(_:)), for: .touchUpInside)
        invisButton3.addTarget(self, action: #selector(setIndex_PushNextStep(_:)), for: .touchUpInside)
        invisButton4.addTarget(self, action: #selector(setIndex_PushNextStep(_:)), for: .touchUpInside)
        
        switch layout {
            //MARK: 2a
        case ._2a:
            self.collageLayoutImageView.image = UIImage(named: "2a_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            
            self.invisButton1.heightAnchor.constraint(equalToConstant: self.screenWidth).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalToConstant: self.screenWidth).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            break
            
            //MARK: 2b
        case ._2b:
            self.collageLayoutImageView.image = UIImage(named: "2b_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            
            self.invisButton1.heightAnchor.constraint(equalToConstant: self.screenWidth/2).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalToConstant: self.screenWidth/2).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton2.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton2.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            break
            
            
            
            //MARK: 3a
        case ._3a:
            self.collageLayoutImageView.image = UIImage(named: "3a_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton3.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            break
            
        //MARK: 3b
        case ._3b:
            self.collageLayoutImageView.image = UIImage(named: "3b_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton2.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton3.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            break
            
        //MARK: 3c
        case ._3c:
            self.collageLayoutImageView.image = UIImage(named: "3c_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.invisButton1.rightAnchor).isActive = true
            self.invisButton2.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            break
           
        //MARK: 3d
        case ._3d:
            self.collageLayoutImageView.image = UIImage(named: "3d_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.invisButton1.bottomAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton3.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            break
            
            //MARK: 4a
        case ._4a:
            self.collageLayoutImageView.image = UIImage(named: "4a_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            self.view.addSubview(invisButton4)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton2.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton3.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.invisButton4.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.5).isActive = true
            self.invisButton4.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            self.invisButton4.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton4.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true

            
            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            self.view.bringSubviewToFront(invisButton4)
            break
            
        //MARK: 4b
        case ._4b:
            self.collageLayoutImageView.image = UIImage(named: "4b_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            self.view.addSubview(invisButton4)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.66).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.66).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.invisButton1.rightAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.66).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton3.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton4.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton4.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton4.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton4.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            self.view.bringSubviewToFront(invisButton4)
            break
            
        //MARK: 4c
        case ._4c:
            self.collageLayoutImageView.image = UIImage(named: "4c_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            self.view.addSubview(invisButton4)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.invisButton1.rightAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton3.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton4.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.66).isActive = true
            self.invisButton4.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.invisButton4.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton4.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            self.view.bringSubviewToFront(invisButton4)
            break
        
        //MARK: 4d
        case ._4d:
            self.collageLayoutImageView.image = UIImage(named: "4d_b")
            
            self.view.addSubview(invisButton1)
            self.view.addSubview(invisButton2)
            self.view.addSubview(invisButton3)
            self.view.addSubview(invisButton4)
            
            self.invisButton1.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton1.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton1.topAnchor.constraint(equalTo: self.collageLayoutImageView.topAnchor).isActive = true
            
            self.invisButton2.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton2.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton2.topAnchor.constraint(equalTo: self.invisButton1.bottomAnchor).isActive = true
            
            self.invisButton3.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33).isActive = true
            self.invisButton3.leftAnchor.constraint(equalTo: self.collageLayoutImageView.leftAnchor).isActive = true
            self.invisButton3.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.invisButton4.heightAnchor.constraint(equalTo: self.collageLayoutImageView.heightAnchor).isActive = true
            self.invisButton4.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.66).isActive = true
            self.invisButton4.rightAnchor.constraint(equalTo: self.collageLayoutImageView.rightAnchor).isActive = true
            self.invisButton4.bottomAnchor.constraint(equalTo: self.collageLayoutImageView.bottomAnchor).isActive = true
            
            self.view.bringSubviewToFront(invisButton1)
            self.view.bringSubviewToFront(invisButton2)
            self.view.bringSubviewToFront(invisButton3)
            self.view.bringSubviewToFront(invisButton4)
            break
        }
    }
}


/*
 adding new layout:
 
 add invis button constraints
 edit collage_draw.drawImages()
 */
