//
//  CoreDataUtil.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData

public enum CoreDataUtilError: Error {
    case appDelegateError
}

public struct CoreDataUtil {
    
    private static var persistentContainer: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: "BananoQuest", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        return mom
    }()
    
    private static func createPersistentContainer() -> NSPersistentContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BananoQuest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    private static func createNSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType, mergePolicy: NSMergePolicy?) throws -> NSManagedObjectContext {
        let persistentContainer = CoreDataUtil.createPersistentContainer()
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
    
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        if let mergePolicy = mergePolicy {
            managedObjectContext.mergePolicy = mergePolicy
        }
    
        return managedObjectContext
    }
    
    public static func mainPersistentContext(mergePolicy: NSMergePolicy?) throws -> NSManagedObjectContext {
        return try CoreDataUtil.createNSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, mergePolicy: mergePolicy)
    }
    
    public static func backgroundPersistentContext(mergePolicy: NSMergePolicy?) throws -> NSManagedObjectContext {
        return try CoreDataUtil.createNSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, mergePolicy: mergePolicy)
    }
    
}
