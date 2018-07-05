//
//  Metadata+CoreDataProperties.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData


extension Metadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Metadata> {
        return NSFetchRequest<Metadata>(entityName: "Metadata")
    }

    @NSManaged public var hexColor: String?
    @NSManaged public var lat1: Float
    @NSManaged public var lat2: Float
    @NSManaged public var lat3: Float
    @NSManaged public var lat4: Float
    @NSManaged public var lon1: Float
    @NSManaged public var lon2: Float
    @NSManaged public var lon3: Float
    @NSManaged public var lon4: Float

}
