//
//  CollectionFolderModel.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/18/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import CloudKit

struct CollectionFolderModel {
    var name: NSString
    var nameUID: NSString
    var picturedObjectRecordID: NSString
    var cKRecord: CKRecord
}
