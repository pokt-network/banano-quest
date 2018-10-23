//
//  Banano+CoreDataProperties.swift
//  
//
//  Created by Pabel Nunez Landestoy on 10/23/18.
//
//

import Foundation
import CoreData


extension Banano {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Banano> {
        return NSFetchRequest<Banano>(entityName: "Banano")
    }

    @NSManaged public var index: String?
    @NSManaged public var questName: String?
    @NSManaged public var hexColor: String?

}
