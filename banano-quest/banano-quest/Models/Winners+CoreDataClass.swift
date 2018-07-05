//
//  Winners+CoreDataClass.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Winners)
public class Winners: NSManagedObject {
    
    convenience init(obj: [AnyHashable: Any]!, context moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.address = obj["address"] as? String
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print("Failed to save Winner with error: \(error)")
        }
    }
    
    func reset() {
        do {
            self.managedObjectContext?.reset()
        }
    }
    
    func delete() {
        do {
            self.managedObjectContext?.delete(self)
            self.save()
        }
    }
    
    func dictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["address"] = address
        
        return dict
    }
}
