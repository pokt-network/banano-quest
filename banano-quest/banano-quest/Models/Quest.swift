//
//  Quest.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public struct Quest {
    var creator: String?
    var name: String?
    var hint: String?
    var merkleRoot: String?
    var maxWinners: Int16?
    var winners: [AnyHashable: Any]?
    var metadata: [AnyHashable: Any]?
    
    public static func getQuestList() -> [Quest] {
        return [Quest.init()]
    }
}
