//
//  Banano+CoreDataClass.swift
//  
//
//  Created by Pabel Nunez Landestoy on 10/23/18.
//
//

import Foundation
import CoreData
import BigInt

@objc(Banano)
public class Banano: NSManagedObject {

    convenience init(obj: Quest, context: NSManagedObjectContext) throws {
        self.init(context: context)
        self.replaceValues(obj: obj, context: context)
    }
    
    // Updates quest instance with dict
    public func replaceValues(obj: Quest, context: NSManagedObjectContext) {
        
        if !obj.name.isEmpty {
            self.questName = obj.name
        }else{
            self.questName = ""
        }
        
        if !(obj.hexColor?.isEmpty ?? true) {
            self.hexColor = obj.hexColor
        }else{
            self.hexColor = ""
        }
        
        do {
            let bananosCount = try getLocalBananoCount(context: context)
            self.index = String.init(BigInt.anyToBigInt(anyValue: bananosCount) ?? BigInt.init(0))
            
        } catch let error as NSError {
            print("Failed with error: \(error)")
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
    
    public static func sortedBananosByIndex(context: NSManagedObjectContext) throws -> [Banano] {
        let fetchRequest: NSFetchRequest<Banano> = Banano.fetchRequest()
        let sort = NSSortDescriptor.init(key: "index", ascending: false, selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sort]
        return try context.fetch(fetchRequest) as [Banano]
    }
    
    public static func getBananosByIndex(questIndex: String, context: NSManagedObjectContext) -> Banano? {
        var result: Banano?
        let fetchRequest: NSFetchRequest<Banano> = Banano.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "index == %@", questIndex)
        
        do {
            let results = try context.fetch(fetchRequest) as [Banano]
            if results.count == 1 {
                result = results.first
            }
        } catch {
            result = nil
        }
        
        return result
    }
    
    func getLocalBananoCount(context: NSManagedObjectContext) throws -> Int64{
        var quests = [Banano]()
        
        let fetchRequest = NSFetchRequest<Banano>(entityName: "Banano")
        
        quests = try context.fetch(fetchRequest) as [Banano]
        
        return Int64(quests.count)
    }
}
