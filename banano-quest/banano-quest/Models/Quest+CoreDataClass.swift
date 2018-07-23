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
    
    convenience init(obj: [AnyHashable: Any], context: NSManagedObjectContext) throws {
        self.init(context: context)
        self.replaceValues(obj: obj)
    }
    
    // Updates quest instance with dict
    public func replaceValues(obj: [AnyHashable: Any]) {
        _ = obj.map { (key, value) -> Void in
            switch key as? String {
            case "index":
                self.index = Int64(value as? String ?? "0") ?? 0
            case "creator":
                self.creator = value as? String
            case "name":
                self.name = value as? String
            case "hint":
                self.hint = value as? String
            case "maxWinners":
                self.maxWinners = Int64(value as? String ?? "0") ?? 0
            case "prize":
                self.prize = Double(value as? String ?? "0.0") ?? 0.0
            case "merkleRoot":
                self.merkleRoot = value as? String
            case "merkleBody":
                self.merkleBody = value as? String
            case "winnersAmount":
                self.winnersAmount = value as? Int64 ?? 0
            case "claimersAmount":
                self.claimersAmount = value as? Int64 ?? 0
            case "isWinner":
                self.isWinner = value as? Bool ?? false
            case "isClaimer":
                self.isClaimer = value as? Bool ?? false
            case "metadata":
                self.metadata = value as? String ?? ""
                if let metadata = self.metadata {
                    let metaElements = metadata.split(separator: ",").map { (substring) -> String in
                        return String.init(substring)
                    }
                    
                    if metaElements.count == 9 {
                        self.hexColor = metaElements[0]
                        self.lat1 = Float(metaElements[1]) ?? 0.0
                        self.lon1 = Float(metaElements[2]) ?? 0.0
                        self.lat2 = Float(metaElements[3]) ?? 0.0
                        self.lon2 = Float(metaElements[4]) ?? 0.0
                        self.lat3 = Float(metaElements[5]) ?? 0.0
                        self.lon3 = Float(metaElements[6]) ?? 0.0
                        self.lat4 = Float(metaElements[7]) ?? 0.0
                        self.lon4 = Float(metaElements[8]) ?? 0.0
                    }
                }
            case .none:
                return
            case .some(_):
                return
            }
        }
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
    
    public static func getQuestByIndex(questIndex: Int64, context: NSManagedObjectContext) -> Quest? {
        var result: Quest?
        let fetchRequest: NSFetchRequest<Quest> = Quest.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "questID == %@", questIndex)
        
        do {
            let results = try context.fetch(fetchRequest) as [Quest]
            if results.count == 1 {
                result = results.first
            }
        } catch {
            result = nil
        }
        
        return result
    }
    
    func getLocalQuestCount(context: NSManagedObjectContext) throws -> Int64{
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        quests = try context.fetch(fetchRequest) as [Quest]

        return Int64(quests.count)
    }
    
    func dictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["index"] = index
        dict["creator"] = creator
        dict["name"] = name
        dict["prize"] = prize
        dict["hint"] = hint
        dict["maxWinners"] = maxWinners
        dict["merkleRoot"] = merkleRoot
        dict["merkleBody"] = merkleBody
        dict["metadata"] = metadata
        dict["winners"] = winners?.dictionary()
        dict["winnersAmount"] = winnersAmount
        dict["claimersAmount"] = claimersAmount
        dict["isWinner"] = isWinner
        dict["isClaimer"] = isClaimer
        
        return dict
    }
}
