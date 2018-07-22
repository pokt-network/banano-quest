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
    
    convenience init(obj: [AnyHashable: Any]!, metadata: [AnyHashable: Any]!, context: NSManagedObjectContext) throws {
        self.init(context: context)
        self.questID = Int64(obj["index"] as? String ?? "0") ?? 0
        self.creator = obj["creator"] as? String
        self.name = obj["name"] as? String
        self.hint = obj["hint"] as? String
        self.maxWinners = Int64(obj["maxWinners"] as? String ?? "0") ?? 0
        self.prize = Double(obj["prize"] as? String ?? "0.0") ?? 0.0
        self.merkleRoot = obj["merkleRoot"] as? String
        self.merkleBody = obj["merkleBody"] as? String
        self.winnersAmount = obj["winnersAmount"] as? Int64 ?? 0
        self.claimersAmount = obj["claimersAmount"] as? Int64 ?? 0
        self.metadata = Metadata(obj: metadata, context: context)
    }
    
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    func reset() throws {
        self.managedObjectContext?.reset()
    }
    
    func delete() throws {
        self.managedObjectContext?.delete(self)
        try self.save()
    }
    
    func getLocalQuestCount(context: NSManagedObjectContext) throws -> Int32{
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        quests = try context.fetch(fetchRequest) as [Quest]

        return Int32(quests.count)
    }
    
    func dictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["questID"] = questID
        dict["creator"] = creator
        dict["name"] = name
        dict["prize"] = prize
        dict["hint"] = hint
        dict["maxWinners"] = maxWinners
        dict["merkleRoot"] = merkleRoot
        dict["merkleBody"] = merkleBody
        dict["metadata"] = metadata?.dictionary()
        dict["winners"] = winners?.dictionary()
        
        return dict
    }
}
