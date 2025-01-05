//
//  LocalUserModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 29/11/24.
//

import Foundation
import SwiftUI

enum HealthType: String, CaseIterable {
    case SleepTime = "SleepTime"
    case CaloryBurn = "CaloryBurn"
    case CalorieIntake = "CalorieIntake"
    case Carbs = "Carbs"
    case Sugar = "Sugar"
    case Protein = "Protein"
    case Fat = "Fat"
    
    static func getType(stringType: String) -> HealthType? {
        return HealthType.allCases.first(where: { $0.rawValue == stringType })
    }
}

struct LocalUserEntity: Hashable, Codable, Equatable {
    var userID: String
    var profile: Data
    var email: String
    var username: String
    var score: Int
    var goals: [String: Double]
    var startStreak: Date?
    var lastStreak: Date?
    
    init(
        userID: String = "",
        profile: Data = Data(),
        email: String = "",
        username: String = "",
        score: Int = 0,
        goals: [String: Double] = [
            HealthType.SleepTime.rawValue: 21600,
            HealthType.CaloryBurn.rawValue: 200,
            HealthType.CalorieIntake.rawValue: 2150,
            HealthType.Carbs.rawValue: 275,
            HealthType.Sugar.rawValue: 50,
            HealthType.Protein.rawValue: 50,
            HealthType.Fat.rawValue: 78
        ]
    ) {
        self.userID = userID
        self.profile = profile
        self.email = email
        self.username = username
        self.score = score
        self.goals = goals
        self.startStreak = nil
        self.lastStreak = nil
    }
    
    func generateImage() -> UIImage {
        return UIImage(data: profile) ?? UIImage(systemName: "person.crop.circle.fill")!
    }
    
    func generateStreakCount() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        guard
            let startDate = startStreak,
            let endDate = lastStreak,
            let start = Int(formatter.string(from: startDate)),
            let end = Int(formatter.string(from: endDate))
        else { return 0 }
        
        return end - start + 1
    }
}
