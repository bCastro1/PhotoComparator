//
//  CoreDataManager.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 1/30/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    //MARK: Core data singleton
    
    static let sharedManager = CoreDataManager()
    //var context: NSManagedObjectContext! = nil

    private init(){  } // Prevent user from creating another instance.
    
    //MARK: Persistent container
    lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "PhotoComparator")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      })
      return container
    }()
    
    //MARK: Save context
    func saveContext () {
      let context = CoreDataManager.sharedManager.persistentContainer.viewContext
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          // Replace this implementation with code to handle the error appropriately.
          // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
      }
    }
    
}
