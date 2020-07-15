//
//  Extensions.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/19/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import UIKit

//MARK: UIColor
extension UIColor {
    static let defaultTint = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    
    private static let primaryThemeColor = UIColor(red: 255/255, green: 191/255, blue: 136/255, alpha: 1) //orange peachy
    private static let secondaryThemeColor = UIColor(red: 4/255, green: 57/255, blue: 60/255, alpha: 1) //dark blue
    //color blind?
    
    static func primaryColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .dynamicPrimaryTheme
        } else {
            return .primaryThemeColor
        }
    }
    
    static func secondaryColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .dynamicSecondaryTheme
        } else {
            return .secondaryThemeColor
        }
    }
    
    
    @available(iOS 13.0, *)
    private static let dynamicPrimaryTheme = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .unspecified, .light: return .primaryThemeColor
            case .dark: return .secondaryThemeColor
            @unknown default:
                fatalError()
        }
    }
    
    @available(iOS 13.0, *)
    private static let dynamicSecondaryTheme = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .unspecified, .light: return .secondaryThemeColor
            case .dark: return .primaryThemeColor
            @unknown default:
                fatalError()
        }
    }
    
    
    static func dynamicBackground() -> UIColor {
        if #available(iOS 13.0, *) {
            return .dynamicBackgroundColor
        } else {
            return .white
        }
    }
    
    static func dynamicText() -> UIColor {
        if #available(iOS 13.0, *) {
            return .dynamicTextColor
        } else {
            return .black
        }
    }
    
    @available(iOS 13.0, *)
    //graphite color when in dark mode, pale white in light mode
    private static let dynamicBackgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .unspecified, .light: return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            case .dark: return UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
            @unknown default:
                fatalError()
        }
    }
    @available(iOS 13.0, *)
    //opposite of dynamic BG color
    private static let dynamicTextColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .unspecified, .light: return UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
            case .dark: return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            @unknown default:
                fatalError()
            }
        }
}


// MARK: Alert Helper Function
func showSimpleAlertWithTitle(_ title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}

//MARK: NSDate
extension NSDate {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: self as Date)
        // convert your model NSString to string date
        let yourDate = formatter.date(from: myString)
        //set date format to model string
        formatter.dateFormat = "dd-MMM-yyyy"
        let stringDate = formatter.string(from: yourDate!)

        return stringDate
    }
    
    func formatDate_DayMonth() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: self as Date)
        // convert your model NSString to string date
        let yourDate = formatter.date(from: myString)
        //set date format to model string
        formatter.dateFormat = "dd-MMM"
        let stringDate = formatter.string(from: yourDate!)

        return stringDate
    }
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}
public func timeFrom(lhs: NSDate, rhs: NSDate) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.allowedUnits = [.year,.month,.day]
    return formatter.string(from: lhs as Date, to: rhs as Date)!
}

extension NSDate: Comparable { }



//MARK:  CATransition
extension CATransition {
    
    func pushFromLeft() -> CATransition {
        self.duration = 0.25
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
    
    func popFromTop() -> CATransition {
        self.duration = 0.25
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromTop
        return self
    }
    
    func popFromBottom() -> CATransition {
        self.duration = 0.25
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromBottom
        return self
    }
}

//MARK: NavigationController
extension UINavigationController {
    func popViewControllers(controllersToPop: Int, animated: Bool) {
        if viewControllers.count > controllersToPop {
            popToViewController(viewControllers[viewControllers.count - (controllersToPop + 1)], animated: animated)
        } else {
            print("Trying to pop \(controllersToPop) view controllers but navigation controller contains only \(viewControllers.count) controllers in stack")
        }
    }
}

//MARK: ViewController
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboardWhenDragging(){
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: ImageView
var gIsZooming = false

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        gIsZooming = true
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}


//MARK: UserDefaults
let kSelectedStorageType = "UserSelectedStorageType"

enum tutorialDefaults {
    case album
    case collage
}

let kAlbumTutorialDefault = "AlbumTutorialDefault"
let kCollageTutorialDefault = "CollageTutorialDefault"

extension UserDefaults{
    //default user selected storage type
    //MARK: Check Login
    func setDefaultStorageType(value: String) {
        set(value, forKey: kSelectedStorageType)
    }
    
    //MARK: Retrieve storage type
    func getDefaultStorageType() -> String{
        return string(forKey: kSelectedStorageType) ?? "Local"
    }
    
    func setTutorialDefault(value: String, tutorialType: tutorialDefaults){
        switch tutorialType {
        case .album:
            set(value, forKey: kAlbumTutorialDefault)
        case .collage:
            set(value, forKey: kCollageTutorialDefault)
        }
    }
    
    func getTutorialDefault(tutorialType: tutorialDefaults) -> String {
        switch tutorialType {
        case .album:
            return string(forKey: kAlbumTutorialDefault) ?? "show"
        case .collage:
            return string(forKey: kCollageTutorialDefault) ?? "show"
        }
    }
}

