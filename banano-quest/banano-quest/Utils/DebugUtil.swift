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
                            
                            // Metadata
                            dict["hexColor"] = "FFBB87"
                            dict["lat1"] = "18.488476"
                            dict["lon1"] = "-69.973723"
                            dict["lat2"] = "18.490114"
                            dict["lon2"] = "-69.972489"
                            dict["lat3"] = "18.489901"
                            dict["lon3"] = "-69.973873"
                            dict["lat4"] = "18.488201"
                            dict["lon4"] = "-69.971803"
                            
                            // Quest
                            dict["index"] = "100\(count)"
                            dict["creator"] = "Pocket"
                            dict["name"] = "Quest#\(count)"
                            dict["prize"] = "1.0"
                            dict["hint"] = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
                            dict["maxWinners"] = "5"
                            dict["merkleRoot"] = "0xb25f1957603c69a2552638fbc3cb025c81c667da5b48570280aaa59156cd997f"
                            dict["merkleBody"] = "0x8d91d180e166ce2a9a797650dde03361b44b4a216d1d8ba2946af131990d19ce,0x16c86d37035c8d4ab0e62770a075c55485ecf810920815ce8e5e06deb238c6e9-0xc6d4e6588a08d944662a0330ff939cbad0feda4ff2ed9c3579075f403d3786b4,0xceb65c9ca663c24c75b4e669f041c2f0460ee22702791289987571bce7c5e9dc,0xede151a3ef91ac2a7adf886eedb3d03de53d2324a54c31b4fe40380e6a57f250,0x47365bcde80be5aff361dca22fe21d4b6a92e48fd62616898be1173440c5a2c3-0x94a71050d27e1969c5a8908e0dc0bb7bcace9dab7146b32d69a0745be65b4cbf,0xb3e61e20ef910dee2226ed4a3924205035b9fb9d6fa46c108a790e341939b322,0x8b4ca335f3ec549629f73b2c5ac14f25d94a74ef63df70f2c10409cff1c8aaf1,0xb17621383d2c55d553b3fa7f1c54de5441bce5d6d44c6e0f603a214deb273ed8,0xce4c4bde6cac015750dfbe4281cb11d2c1430ae236621583bfde56a5eff97aaa,0xf15ab4e5978c69a9a5b6ff60a874e289c259435b81d1ce5b089753d61bda2cb8,0x8b66965b806b5f6a648860080eefae3671d931594a1056152b30a8617136bc2f,0x453d9bc094793e69e8e88f112007a32acbb4e3a658beeab2f2cc5f3e41ba61d7"
                            
                            do{
                                let quest = try Quest(obj: dict, context: BaseUtil.mainContext)
                                try quest.save()
                            } catch let error as NSError {
                                print("Failed to create quest with error: \(error)")
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
