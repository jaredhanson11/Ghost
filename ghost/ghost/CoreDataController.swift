//
//  CoreDataController.swift
//  ghost
//
//  Created by John Clarke on 7/30/16.
//  Copyright © 2016 hck. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataController: NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    override  init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("Cache", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.URLByAppendingPathComponent("Up_and_Running_With_Core_Data.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func deleteFromCoreData(entity: String){
        let object = self.managedObjectContext
        let objectFetch = NSFetchRequest(entityName: entity)
        
        do {
            let fetchedObjects = try object.executeFetchRequest(objectFetch)
            if (fetchedObjects.count != 0) {
                for i in 0...(fetchedObjects.count-1) {
                    let fetchedObject = fetchedObjects[i] as! NSManagedObject
                    object.deleteObject(fetchedObject)
                }
            }
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        do {
            try object.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    func clearCoreData(entities: [String]) {
        for i in 0...(entities.count-1) {
            let entity: String = entities[i]
            deleteFromCoreData(entity)
        }
    }
    
    func saveToCoreData(entityName : String, data: [String:String]) {
        let managedContext = self.managedObjectContext
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext:managedContext)
        let object = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        for i in 0...(data.count-1) {
            let label = Array(data.keys)[i]
            object.setValue(data[label], forKey: label)
        }
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // returns a string of message ids to be delete (userid, messageid) sufficient to identify an exact message displayed in a users conversations
    func fetchEntitiesToDelete(entity : String) -> String {
        let key = (entity as NSString).substringToIndex(entity.characters.count-1) + "_id"
        var entityIDs: [String] = [String]()
        let object = self.managedObjectContext
        let objectFetch = NSFetchRequest(entityName: entity)
        do {
            let fetchedObjects = try object.executeFetchRequest(objectFetch)
            if (!fetchedObjects.isEmpty) {
                for i in 0...(fetchedObjects.count-1) {
                    let fetchedObject = fetchedObjects[i] as! NSManagedObject
                    let entityID: String = fetchedObject.valueForKey(key) as! String
                    entityIDs.append(entityID)
                }
            }
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
        return entityIDs.joinWithSeparator(",")
    }
    
    static let sharedInstance = CoreDataController()
}