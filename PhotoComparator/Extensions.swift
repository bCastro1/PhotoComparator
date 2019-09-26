//
//  Extensions.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/19/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let defaultTint = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
}


// MARK: Helper Function
func showSimpleAlertWithTitle(_ title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}

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
}
