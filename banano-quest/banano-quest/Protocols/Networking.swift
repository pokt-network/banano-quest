//
//  Networking.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public protocol Networking {
    func getQuestList() -> [Quest]
    func createQuest(quest: Quest) -> Bool
    func completeQuest(quest: Quest) -> Bool
}
