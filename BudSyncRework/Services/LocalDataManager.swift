//
//  LocalDataManager.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 23/12/24.
//

import Foundation
import SwiftUI

class LocalDataManager {
    static let shared = LocalDataManager()
    
    func saveUser(userData: LocalUserEntity) {
        do {
            let userData = try JSONEncoder().encode(userData)
            UserDefaults.standard.set(userData, forKey: "LocalUser")
        } catch {
            print("Error saving user data: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() -> LocalUserEntity? {
        guard
            let userData = UserDefaults.standard.data(forKey: "LocalUser"),
            let user = try? JSONDecoder().decode(LocalUserEntity.self, from: userData)
        else {
            return nil
        }
        
        return user
    }
    
    func saveChanges(userData: LocalUserEntity) {
        guard var user = fetchUser() else { return }
        user.profile = userData.profile
        user.email = userData.email
        user.username = userData.username
        user.score = userData.score
        user.goals = userData.goals
        user.startStreak = userData.startStreak
        user.lastStreak = userData.lastStreak
        saveUser(userData: user)
    }
    
    func updateScore(score: Int) {
        guard var user = fetchUser() else { return }
        user.score = score
        saveUser(userData: user)
    }
    
    func updateStreak(start: Date?, last: Date?) {
        guard var user = fetchUser() else { return }
        user.startStreak = start
        user.lastStreak = last
        saveUser(userData: user)
    }
    
    func removeAccount() {
        UserDefaults.standard.removeObject(forKey: "LocalUser")
    }
    
    func checkIsRegistered() -> Bool {
        if fetchUser() != nil {
            return true
        }
        
        return false
    }
}
