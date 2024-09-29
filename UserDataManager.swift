//
//  UserDataManager.swift
//  GTFO
//
//  Created by Valerie Williams on 9/29/2024
//

import Foundation

class UserDataManager {
    
    static let shared = UserDataManager()
    private let userDefaults = UserDefaults.standard
        
    private init() {}
    
    // Keys
    private let onboardedKey = "isOnboarded"
    
    // Save onboarding status
    func saveOnboardedStatus(_ onboarded: Bool)
    {
        UserDefaults.standard.set(onboarded, forKey: onboardedKey)
    }

    // Retrieve onboard status
    func loadOnboardStatus() -> Bool
    {
        return UserDefaults.standard.bool(forKey: onboardedKey)
    }
    
}
