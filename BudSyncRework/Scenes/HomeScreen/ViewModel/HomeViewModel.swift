//
//  HomeViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var currUser = LocalUserEntity()
    
    @Published var overallProgress = 0.0
    @Published var energyBurnProgress = 0.0
    @Published var sleepTimeProgress = 0.0
    @Published var calorieIntakeProgress = 0.0
    @Published var carbsProgress = 0.0
    @Published var proteinProgress = 0.0
    @Published var fatProgress = 0.0
    @Published var sugarProgress = 0.0
    
    @Published var streakCount = 0
    @Published var currentImage = "Seedling"
    
    @Published var showToast = false
    @Published var inputResult = false
    @Published var profileImage = UIImage(systemName: "person.crop.circle")!
    
    static let shared = HomeViewModel()
    private let localDB = LocalDataManager.shared
    private let cloudDB = CloudKitManager.shared
    private let healthMng = HealthKitManager.shared
    
    func setUpViewModel() {
        fetchCurrentUser()
        setUpStreak()
        setUpHealthData()
    }
    
    func fetchCurrentUser() {
        guard let user = localDB.fetchUser() else {
            return
        }
        currUser = user
        profileImage = currUser.generateImage()
    }
    
    func setUpStreak() {
        if checkStreak() > 1 {
            streakCount = 0
        } else {
            streakCount = currUser.generateStreakCount()
        }
    }
    
    func inputNutrientData(calorie: Double, carbs: Double, sugar: Double, protein: Double, fat: Double) {
        let calorieGoal = currUser.goals[HealthType.CalorieIntake.rawValue] ?? 2150.0
        let carbsGoal = currUser.goals[HealthType.Carbs.rawValue] ?? 300.0
        let sugarGoal = currUser.goals[HealthType.Sugar.rawValue] ?? 50.0
        let proteinGoal = currUser.goals[HealthType.Protein.rawValue] ?? 50.0
        let fatGoal = currUser.goals[HealthType.Fat.rawValue] ?? 75.0
        
        calorieIntakeProgress += (calorie/calorieGoal) * 0.8
        carbsProgress += (carbs/carbsGoal) * 0.8
        proteinProgress += (protein/proteinGoal) * 0.8
        fatProgress += (fat/fatGoal) * 0.8
        sugarProgress += (sugar/sugarGoal) * 0.8
        calculateOverallProgress()
        
        healthMng.postQuantityType(
            input: calorie, type: HealthType.CalorieIntake
        )
        healthMng.postQuantityType(
            input: carbs, type: HealthType.Carbs
        )
        healthMng.postQuantityType(
            input: protein, type: HealthType.Protein
        )
        healthMng.postQuantityType(
            input: fat, type: HealthType.Fat
        )
        healthMng.postQuantityType(
            input: sugar, type: HealthType.Sugar
        )
        
        withAnimation(.easeIn(duration: 1)) {
            showToast = true
        }
        
        inputResult = true
    }
    
    func setUpHealthData() {
        Task {
            let sleep = await healthMng.fetchSleepTimeInSec()
            let sleepgoal = (currUser.goals[HealthType.SleepTime.rawValue] ?? 6.0) * 3600
            
            let energy = await healthMng.fetchQuantityType(type: HealthType.CaloryBurn)
            let energygoal = currUser.goals[HealthType.CaloryBurn.rawValue] ?? 200.0
            
            let protein = await healthMng.fetchQuantityType(type: HealthType.Protein)
            let proteingoal = currUser.goals[HealthType.Protein.rawValue] ?? 50.0
            
            let fat = await healthMng.fetchQuantityType(type: HealthType.Fat)
            let fatgoal = currUser.goals[HealthType.Fat.rawValue] ?? 75.0
            
            let carbs = await healthMng.fetchQuantityType(type: HealthType.Carbs)
            let carbgoal = currUser.goals[HealthType.Carbs.rawValue] ?? 300.0
            
            let calorie = await healthMng.fetchQuantityType(type: HealthType.CalorieIntake)
            let caloriegoal = currUser.goals[HealthType.CalorieIntake.rawValue] ?? 2000.0
            
            let sugar = await healthMng.fetchQuantityType(type: HealthType.Sugar)
            let sugargoal = currUser.goals[HealthType.Sugar.rawValue] ?? 50.0
            
            DispatchQueue.main.async {
                self.sleepTimeProgress = (sleep/sleepgoal) * 0.8
                self.energyBurnProgress = (energy/energygoal) * 0.8
                self.proteinProgress = (protein/proteingoal) * 0.8
                self.fatProgress = (fat/fatgoal) * 0.8
                self.carbsProgress = (carbs/carbgoal) * 0.8
                self.calorieIntakeProgress = (calorie/caloriegoal) * 0.8
                self.sugarProgress = (sugar/sugargoal) * 0.8
                self.calculateOverallProgress()
            }
        }
    }
    
    func calculateOverallProgress() {
        let calorieIntake = calorieIntakeProgress <= 0.8 ? calorieIntakeProgress : 1.6 - calorieIntakeProgress
        let carbs = carbsProgress <= 0.8 ? carbsProgress : 1.6 - carbsProgress
        let fat = fatProgress <= 0.8 ? fatProgress : 1.6 - fatProgress
        let sugar = sugarProgress <= 0.8 ? sugarProgress : 1.6 - sugarProgress
        
        let overallData = energyBurnProgress + sleepTimeProgress + calorieIntake + carbs + proteinProgress + fat + sugar
        overallProgress = (overallData/8) * 1.25
        updateStreak()
        updateAssetsImage()
        
        Task {
            let score = Int(overallProgress * 100)
            localDB.updateScore(score: score)
            
            if !currUser.userID.isEmpty {
                _ = await cloudDB.updateScore(userID: currUser.userID, newScr: score)
            }
        }
    }
    
    func updateStreak() {
        if overallProgress >= 1.0 {
            if currUser.startStreak == nil {
                localDB.updateStreak(start: Date.now, last: Date.now)
            } else {
                if checkStreak() > 1 {
                    localDB.updateStreak(start: Date.now, last: Date.now)
                } else if checkStreak() == 1 {
                    localDB.updateStreak(start: currUser.startStreak, last: Date.now)
                    streakCount += 1
                    return
                }
            }
            streakCount = 1
        } else {
            if checkStreak() == 0 {
                if currUser.generateStreakCount() == 1 {
                    localDB.updateStreak(start: nil, last: nil)
                    streakCount = 0
                } else {
                    let calendar = Calendar(identifier: .gregorian)
                    let date = calendar.date(byAdding: .day, value: -1, to: Date.now)
                    localDB.updateStreak(start: currUser.startStreak, last: date)
                    if streakCount > 0 {
                        streakCount -= 1
                    }
                }
            }
        }
    }
    
    func updateAssetsImage() {
        if overallProgress < 0.3 {
            currentImage = "Seedling"
        } else if overallProgress < 0.65 {
            currentImage = "Sapling"
        } else if overallProgress < 1.0 {
            currentImage = "YoungTree"
        } else if overallProgress < 1.0 {
            currentImage = "AdultTree"
        } else if overallProgress >= 1.2 {
            if fatProgress <= 0.8 && sugarProgress <= 0.8 && calorieIntakeProgress <= 0.8 && carbsProgress <= 0.8 {
                currentImage = "AdultTree"
            } else {
                currentImage = "FullBloom"
            }
        }
    }
    
    func checkStreak() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        guard
            let curr = Int(formatter.string(from: Date.now)),
            let lastDay = currUser.lastStreak,
            let lastCounted = Int(formatter.string(from: lastDay))
        else { return 0 }
        
        return curr - lastCounted
    }
    
    func getTextInfo(state: HealthType) -> String {
        switch state {
        case .SleepTime:
            let goal = currUser.goals[HealthType.SleepTime.rawValue] ?? 6.0
            let value = sleepTimeProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) hour"
        case .CaloryBurn:
            let goal = currUser.goals[HealthType.CaloryBurn.rawValue] ?? 200.0
            let value = energyBurnProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) kcal"
        case .CalorieIntake:
            let goal = currUser.goals[HealthType.CalorieIntake.rawValue] ?? 2150.0
            let value = calorieIntakeProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) kcal"
        case .Carbs:
            let goal = currUser.goals[HealthType.Carbs.rawValue] ?? 300.0
            let value = carbsProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) gr"
        case .Sugar:
            let goal = currUser.goals[HealthType.Sugar.rawValue] ?? 50.0
            let value = sugarProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) gr"
        case .Protein:
            let goal = currUser.goals[HealthType.Protein.rawValue] ?? 50.0
            let value = proteinProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) gr"
        case .Fat:
            let goal = currUser.goals[HealthType.Fat.rawValue] ?? 75.0
            let value = fatProgress * goal / 0.8
            return String(format: "%.2f", value) + "\nof\n\(goal) gr"
        }
    }
}
