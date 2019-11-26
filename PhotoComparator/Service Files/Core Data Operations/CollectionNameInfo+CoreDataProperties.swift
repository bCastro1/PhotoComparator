//
//  CollectionNameInfo+CoreDataProperties.swift
//  
//
//  Created by Brendan Castro on 11/7/19.
//
//

import Foundation
import CoreData


extension CollectionNameInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CollectionNameInfo> {
        return NSFetchRequest<CollectionNameInfo>(entityName: "CollectionNameInfo")
    }

    @NSManaged public var name: String?
    @NSManaged public var nameUID: String?
    @NSManaged public var pictureID: String?
    @NSManaged public var collectionName: FullResolution?

}
