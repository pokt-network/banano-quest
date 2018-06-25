//
//  BananoQuest.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public class BananoQuest: Networking {
    
    public func getQuestList() -> [Quest] {
        return [Quest()]
    }
    
    public func createQuest(quest: Quest) -> Bool {
        return false
    }
    
    public func completeQuest(quest: Quest) -> Bool {
        return false
    }
    
}
