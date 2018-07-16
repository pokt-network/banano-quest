//
//  DebugUtil.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/14/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

public class DebugUtil {
    // Change isDebug to true or false to enable dummy data for testing.
    static var isDebug = true
    
    // Creates 10 dummy quests and saves them into CoreData
    // Only if there are 0 quests saved locally
    public static func debugDataSetup() {
        // Only for testing
        if self.isDebug {
            do {
                try Quest.retrieveQuestList { (quests, error) in
                    var count = 0
                    if quests?.count == 0 || quests == nil{
                        while count <= 10 {
                            var dict = [AnyHashable : Any]()
                            var metadata = [AnyHashable : Any]()
                            
                            // Metadata
                            metadata["hexColor"] = "31AADE"
                            metadata["lat1"] = "18.488476"
                            metadata["lon1"] = "-69.973723"
                            metadata["lat2"] = "18.490114"
                            metadata["lon2"] = "-69.972489"
                            metadata["lat3"] = "18.489901"
                            metadata["lon3"] = "-69.973873"
                            metadata["lat4"] = "18.488201"
                            metadata["lon4"] = "-69.971803"
                            
                            // Quest
                            dict["questID"] = "100\(count)"
                            dict["creator"] = "Pocket"
                            dict["name"] = "Quest#\(count)"
                            dict["prize"] = "1.0"
                            dict["hint"] = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
                            dict["maxWinners"] = "5"
                            dict["merkleRoot"] = "DOEIUFDH230I43EHT09FJEQ0WREJR0DGJ3294H3REOSF8DGQWOEUIHS0FUI"
                            
                            do{
                                let quest = try Quest(obj: dict, metadata: metadata, context: BaseUtil.mainContext)
                                try quest.save()
                            } catch let error as NSError {
                                print("Failed to create ques with error: \(error)")
                            }
                            count = count + 1
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to retrieve local quest list with error: \(error)")
            }
        }
    }
}
