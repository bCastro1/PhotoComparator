//
//  PlantIndexVC.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 4/20/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class Index: CollectionViewController, AVCapturePhotoCaptureDelegate {
    
    //Trefle api token: OVY3MlRWWE1KeWNkcllSWGRxRjZ4dz09
    var pho: AVCaptureOutput?
    var coreDataFunctions: CoreDataFunctions?
    var cloudkitOperations: CloudKitFunctions?
    let trefleAPI_Token: String = "OVY3MlRWWE1KeWNkcllSWGRxRjZ4dz09"
    
    var cameraController = CameraController()
    
    init(coreDataFunctions: CoreDataFunctions, cloudKitOperations: CloudKitFunctions){
        super.init(nibName: nil, bundle: nil)
        self.coreDataFunctions = coreDataFunctions
        self.cloudkitOperations = cloudKitOperations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicBackground()
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        //loadTrefleData()

        
        view.addSubview(camButton)
        camButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        camButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        camButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        camButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
//        func configureCameraController(){
//            cameraController.prepare {(error) in
//                   if let error = error {
//                       print(error)
//                   }
//
//                   try? self.cameraController.displayPreview(on: self.preview)
//               }
//        }
//
//       func styleCaptureButton() {
//           camButton.layer.borderColor = UIColor.black.cgColor
//           camButton.layer.borderWidth = 2
//
//           camButton.layer.cornerRadius = min(camButton.frame.width, camButton.frame.height) / 2
//       }
//        styleCaptureButton()
//        configureCameraController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Explore"
    }

    var camButton: UIButton = {
        var button = UIButton(type: .system)
        button.backgroundColor = .secondaryColor()
        button.setTitle("Camera", for: .normal)
        button.addTarget(self, action: #selector(cam), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func cam(){
        print("present cam")
        let cameraVC = CameraCaptureVC(coreDataFunctions: self.coreDataFunctions!, cloudKitOperations: self.cloudkitOperations!)
        cameraVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     curl -i -X POST "https://trefle.io/api/auth/claim?token=YOUR-TOKEN&origin=YOUR-WEBSITE-URL"

     #
     If you need to perform client-side requests, you will have to request a client-side token from you backend, and get a JWT token in return. This token will be usable on the client side. This call need you secret access token, and the url of the website the client side requests will come from.

     For example, with curl:
     
     >{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpcCI6Ijc4LjE5Mi4yNTEuNzEiLCJpc3N1ZXJfaWQiOjEwNiwib3JpZ2luIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20iLCJhdWQiOiJKb2tlbiIsImV4cCI6MTU1NTU1NDE4NywiaWF0IjoxNTU1NTQ2OTg3LCJpc3MiOiJKb2tlbiIsImp0aSI6IjJtYjZqZmpiZ3ZmZTQwczFvZzAwMDBnMiIsIm5iZiI6MTU1NTU0Njk4N30.H_Hf9lcInPy1H9myBglKJcxSqbvMLbZjJcLlDfFDsWs","expiration":1555554187}

     
     You can then use the given token directly from the browser, as it can't be shared, will expires and will only works for your website.

     Note: You can additionaly also put the user remote IP
     
     curl -i -X POST "https://trefle.io/api/auth/claim?token=YOUR-TOKEN&origin=YOUR-WEBSITE-URL&ip=12.34.56.78"
     */
    
    
//    func loadTrefleData(){
//
//        let url = URL(string: "https://trefle.io/api/plants?q=rosemary&token=\(trefleAPI_Token)")
//        //let url = URL(string: "http://headers.jsontest.com/")
//        //let url = URL(string: "https://trefle.io/api/plants?q=rosemary&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpcCI6WzQ4LDQ2LDQ4LDQ2LDQ4LDQ2LDQ4XSwiaXNzdWVyX2lkIjo0NDIyLCJvcmlnaW4iOiJ2aWN0b3J5ZHJ2Lm1vYmkiLCJhdWQiOiJKb2tlbiIsImV4cCI6MTU4NzYwMDcyNCwiaWF0IjoxNTg3NTkzNTI0LCJpc3MiOiJKb2tlbiIsImp0aSI6IjJvNDQ3cGg5MXJvcnJzdWxjczAwMDBpMSIsIm5iZiI6MTU4NzU5MzUyNH0.ks5_un1Pg7K8AEnbhnOYvCVDfQc2jmLwMmGW0UIVtLs")
//        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//          // your code here
//            if error != nil {
//                print("error: \(String(describing: error))")
//            }
//            else {
//                print("response: \(String(describing: response))")
//            }
//        })
//
//        task.resume()
//    }
    
    
    
}
