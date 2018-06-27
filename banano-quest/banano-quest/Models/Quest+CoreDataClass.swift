//
//  Quest+CoreDataClass.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Quest)
public class Quest: NSManagedObject {
    
    convenience init(obj: [AnyHashable: Any]!, context: NSManagedObjectContext) {
        self.init(context: context)
        self.questID = getLocalQuestCount(context: context) + 1
        self.creator = obj["creator"] as? String
        self.name = obj["name"] as? String
        self.hint = obj["hint"] as? String
        self.maxWinners = (obj["maxWinners"] as? Int16) ?? 0
        self.merkleRoot = obj["merkleRoot"] as? String
        self.metadata = Metadata(obj: obj["metadata"] as? [AnyHashable:Any], context: context)
        self.winners = Winners(obj: obj["metadata"] as? [AnyHashable:Any], context: context)
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            print("Failed to save Quest with error: \(error)")
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
    
    private func getLocalQuestCount(context: NSManagedObjectContext) -> Int32{
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        do {
            quests = try context.fetch(fetchRequest) as [Quest]
        } catch let error as NSError {
            print("Failed to fetch local Quests count with error: \(error)")
        }
        
        return Int32(quests.count)
    }
    
    func dictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["questID"] = questID
        dict["creator"] = creator
        dict["hint"] = hint
        dict["maxWinners"] = maxWinners
        dict["merkleRoot"] = merkleRoot
        dict["metadata"] = metadata?.dictionary()
        dict["winners"] = winners?.dictionary()
        
        return dict
    }
}
