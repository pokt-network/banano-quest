//
//  Winners+CoreDataProperties.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData


extension Winners {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Winners> {
        return NSFetchRequest<Winners>(entityName: "Winners")
    }

    @NSManaged public var address: String?

}
