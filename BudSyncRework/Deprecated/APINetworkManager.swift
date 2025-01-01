////
////  FoodVisorNetworkManager.swift
////  BudSyncRework
////
////  Created by Stevans Calvin Candra on 12/12/24.
////
//
//import Foundation
//
//class APINetworkManager {
//    #warning("Retrieved key")
//    private let apiKey: String = ""
//    
//    func analyzeFood(foodImage: Data) async -> AnalysisResult? {
//        var request = URLRequest(url: URL(string: "https://vision.foodvisor.io/api/1.0/en/analysis/")!)
//        request.addValue("Api-Key " + apiKey, forHTTPHeaderField: "Authorization")
//        request.httpMethod = "POST"
//        request.httpBody = foodImage
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(for: request)
//            let analysedData = try JSONDecoder().decode(AnalysisResult.self, from: data)
//            print(data)
//            
//            return analysedData
//        } catch {
//            print("Failed Retrieving Food Analysis")
//            return nil
//        }
//    }
//}
