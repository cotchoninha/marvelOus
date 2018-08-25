//
//  DataBaseController.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import CoreData

class DataBaseController{
    
    private init(){
        //private to prevent creation of an instance of DataBaseController
    }
    
    //MARK: CoreDataStack
    
    class func getContext() -> NSManagedObjectContext{
        return DataBaseController.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MarvelOus")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = DataBaseController.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

