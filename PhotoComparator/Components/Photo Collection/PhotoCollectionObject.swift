//
//  PhotoCollectionObject.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 9/27/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import CloudKit

struct PhotoCollectionObject {
    
    var date: NSDate
    var photo: UIImage
    var id: String
    let name: String
    var ckrecordID: CKRecord.ID
    var hideBlurView: Bool
    
}
