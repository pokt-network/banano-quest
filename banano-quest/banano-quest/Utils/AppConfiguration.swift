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
    public static let tavernAddress = "0xd480083db34e8c87987652ee90f41ddb311f37ff"
    public static let bananoTokenAddress = "0x75ff16d15dfe4c3a92c97f11ff41644d790035a2"
    public static let chainID = 4
    public static let subnetwork = "4"
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
