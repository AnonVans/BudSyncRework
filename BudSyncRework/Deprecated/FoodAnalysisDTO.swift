////
////  FoodAnalysisDTO.swift
////  BudSyncRework
////
////  Created by Stevans Calvin Candra on 18/12/24.
////
//
//import Foundation
//
//enum NutritionItems: String {
//    case Calorie = "calories_100g"
//    case Protein = "proteins_100g"
//    case Fat = "fat_100g"
//    case Carbohydrate = "carbs_100g"
//    case Fiber = "fibers_100g"
//    case Sugar = "sugars_100g"
//}
//
//struct AnalysisResult: Codable {
//    let scopes: [String]
//    let items: [AnalysisItem]
//    
//    func getOverallCalorie() -> Double {
//        var returnedValue = 0.0
//        for item in items {
//            returnedValue += item.food.food_info.getCalorieIntake()
//        }
//        return returnedValue
//    }
//    
//    func getOverallCarbs() -> Double {
//        var returnedValue = 0.0
//        for item in items {
//            returnedValue += item.food.food_info.getCarbs()
//        }
//        return returnedValue
//    }
//    
//    func getOverallProtein() -> Double {
//        var returnedValue = 0.0
//        for item in items {
//            returnedValue += item.food.food_info.getProtein()
//        }
//        return returnedValue
//    }
//    
//    func getOverallFat() -> Double {
//        var returnedValue = 0.0
//        for item in items {
//            returnedValue += item.food.food_info.getFat()
//        }
//        return returnedValue
//    }
//    
//    func getOverallSugar() -> Double {
//        var returnedValue = 0.0
//        for item in items {
//            returnedValue += item.food.food_info.getSugar()
//        }
//        return returnedValue
//    }
//}
//
//struct AnalysisItem: Codable {
//    let food: FoodAnalysis
//}
//
//struct FoodAnalysis: Codable {
//    let confidance: Double
//    let ingredients: [String]
//    let food_info: FoodInfo
//}
//
//struct FoodInfo: Codable {
//    let food_id: String
//    let display_name: String
//    let g_per_serving: Double
//    let nutrition: [String: Double?]
//    
//    func getCalorieIntake() -> Double {
//        guard let data = nutrition[NutritionItems.Calorie.rawValue] else {
//            return 0.0
//        }
//        return (g_per_serving/100) * (data ?? 0.0)
//    }
//    
//    func getCarbs() -> Double {
//        guard let data = nutrition[NutritionItems.Carbohydrate.rawValue] else {
//            return 0.0
//        }
//        return (g_per_serving/100) * (data ?? 0.0)
//    }
//    
//    func getProtein() -> Double {
//        guard let data = nutrition[NutritionItems.Protein.rawValue] else {
//            return 0.0
//        }
//        return (g_per_serving/100) * (data ?? 0.0)
//    }
//    
//    func getFat() -> Double {
//        guard let data = nutrition[NutritionItems.Fat.rawValue] else {
//            return 0.0
//        }
//        return (g_per_serving/100) * (data ?? 0.0)
//    }
//    
//    func getSugar() -> Double {
//        guard let data = nutrition[NutritionItems.Sugar.rawValue] else {
//            return 0.0
//        }
//        return (g_per_serving/100) * (data ?? 0.0)
//    }
//}
