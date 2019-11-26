//
//  FullResolution+CoreDataProperties.swift
//  
//
//  Created by Brendan Castro on 11/7/19.
//
//

import Foundation
import CoreData


extension FullResolution {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FullResolution> {
        return NSFetchRequest<FullResolution>(entityName: "FullResolution")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var nameUID: String?
    @NSManaged public var pictureName: CollectionNameInfo?

}
