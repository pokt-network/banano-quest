//
//  CoreDataUtil.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
    
    private static func createNSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType, mergePolicy: NSMergePolicy?) throws -> NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw CoreDataUtilError.appDelegateError
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
    
        managedObjectContext.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
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
