//
//  Configuration.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public struct AppConfiguration {
    
    // TODO pull this from "environment"
    public static let tavernAddress = "0xcd4b7ed0c227fa259e8851fafed9bc88430eebab"
    public static let bananoTokenAddress = "0x822b22c36b07a116affaf294484697cff8a505e7"
    public static let chainID = 4
    private static let displayedOnboardingKey = "displayedOnboarding"
    
    public static func clearUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else {
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    public static func displayedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: displayedOnboardingKey)
    }
    
    public static func setDisplayedOnboarding(displayedOnboarding: Bool) {
        UserDefaults.standard.set(displayedOnboarding, forKey: displayedOnboardingKey)
    }
    
}
