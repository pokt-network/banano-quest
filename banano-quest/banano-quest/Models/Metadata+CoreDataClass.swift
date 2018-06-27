//
//  Metadata+CoreDataClass.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Metadata)
public class Metadata: NSManagedObject {
    convenience init(obj: [AnyHashable: Any]!, context moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.hexColor = obj["hexColor"] as? String
        self.lat1 = obj["lat1"] as? Float ?? 0
        self.lon1 = obj["lon1"] as? Float ?? 0
        self.lat2 = obj["lat2"] as? Float ?? 0
        self.lon2 = obj["lon2"] as? Float ?? 0
        self.lat3 = obj["lat3"] as? Float ?? 0
        self.lon3 = obj["long3"] as? Float ?? 0
        self.lat4 = obj["lat4"] as? Float ?? 0
        self.lon4 = obj["lon4"] as? Float ?? 0
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print("Failed to save Metadata with error: \(error)")
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
        dict["hexColor"] = hexColor
        dict["lat1"] = lat1
        dict["lon1"] = lon1
        dict["lat2"] = lat2
        dict["lon2"] = lon2
        dict["lat3"] = lat3
        dict["lon3"] = lon3
        dict["lat4"] = lat4
        dict["lon4"] = lon4
        
        return dict
    }
}
