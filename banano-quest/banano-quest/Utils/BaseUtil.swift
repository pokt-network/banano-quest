//
//  BaseUtil.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/4/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

public class BaseUtil {    
    public static var mainContext: NSManagedObjectContext {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                return context
            }
            appDelegate.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            return appDelegate.persistentContainer.viewContext
        }
    }
    
    public static func retrieveDataFrom(address: String) -> [String] {
        let stringArray = address.components(separatedBy: "/")
        return stringArray
    }
}
