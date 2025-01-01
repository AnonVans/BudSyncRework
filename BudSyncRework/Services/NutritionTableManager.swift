//
//  NutrionTableManager.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 26/12/24.
//

import Foundation
import Vision
import SwiftUI

class NutritionTableManager: ObservableObject {
    @Published var isLoading = false
    @Published var calorie = 0.0
    @Published var carbs = 0.0
    @Published var sugar = 0.0
    @Published var protein = 0.0
    @Published var fat = 0.0
    
    private let homeVM = HomeViewModel.shared
    
    func scanImage(image: UIImage?) {
        calorie = 0
        let cases = [
            "karbohidrat", "carbohydrate", "gula", "sugar", "protein",
            "lemak", "fat", "kolesterol", "cholesterol", "serat",
            "fiber", "vitamin", "garam", "salt", "sodium"
        ]
        var nutrientComponents = [String]()
        var nutrientValues = [Double]()
        
        guard
            let input = image?.optimizeScale(),
            let cgImage = input.cgImage
        else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let scanRequest = VNRecognizeTextRequest()
        
        do {
            try requestHandler.perform([scanRequest])
            
            guard let scanResults = scanRequest.results else {
                isLoading = false
                return
            }
            
            for result in scanResults {
                let scannedText = result.topCandidates(1).first?.string ?? ""
                
                if scannedText.isEmpty {
                    continue
                } else {
                    var processText = scannedText.lowercased()
                    let deletePattern = "\\d+\\ *\\%"
                    let savePattern = "\\d+( m*g)"
                    let caloriePattern = "\\d+( k[k*c*]al)"
                    
                    print(processText)
                    
                    guard
                        let deleteRegex = try? NSRegularExpression(pattern: deletePattern, options: []),
                        let saveRegex = try? NSRegularExpression(pattern: savePattern, options: []),
                        let calorieRegex = try? NSRegularExpression(pattern: caloriePattern, options: [])
                    else {
                        isLoading = false
                        return
                    }
                    
                    for component in cases {
                        if processText.contains(component) && !processText.contains("energi") && !processText.contains("energy") {
                            nutrientComponents.append(processText)
                        }
                    }
                    
                    let range = NSRange(processText.startIndex..., in: processText)
                    deleteRegex.enumerateMatches(in: processText, range: range) { match, _, _ in
                        guard
                            let matchRange = match?.range,
                            let stringRange = Range(matchRange, in: processText)
                        else {
                            isLoading = false
                            return
                        }
                        
                        processText.replaceSubrange(stringRange, with: "")
                    }
                    
                    let newRange = NSRange(processText.startIndex..., in: processText)
                    calorieRegex.enumerateMatches(in: processText, range: newRange) { match, _, _ in
                        guard
                            let matchRange = match?.range,
                            let stringRange = Range(matchRange, in: processText)
                        else {
                            isLoading = false
                            return
                        }
                        
                        let calorieString = String(processText[stringRange])
                        print(calorieString)
                        let value = extractNumber(string: calorieString)
                        
                        if calorie < value {
                            calorie = value
                        }
                    }
                    
                    saveRegex.enumerateMatches(in: processText, range: newRange) { match, _, _ in
                        guard
                            let matchRange = match?.range,
                            let stringRange = Range(matchRange, in: processText)
                        else {
                            isLoading = false
                            return
                        }
                        
                        let saveString = String(processText[stringRange])
                        print(saveString)
                        let value = extractNumber(string: saveString)
                        nutrientValues.append(value)
                    }
                }
            }
            
            if let idx = nutrientComponents.firstIndex(where: { $0.contains("karbohidrat") || $0.contains("carbohydrate") }) {
                carbs = nutrientValues[idx]
            } else {
                carbs = 0
            }
            
            if let idx = nutrientComponents.firstIndex(where: { $0.contains("gula") || $0.contains("sugar") }) {
                sugar = nutrientValues[idx]
            } else {
                sugar = 0
            }
            
            if let idx = nutrientComponents.firstIndex(where: { $0.contains("protein") }) {
                protein = nutrientValues[idx]
            } else {
                protein = 0
            }
            
            if let idx = nutrientComponents.firstIndex(where: { $0.contains("lemak total") || $0.contains("total fat") }) {
                fat = nutrientValues[idx]
            } else {
                fat = 0
            }
            
        } catch {
            isLoading = false
            print("Failed scanning image for text: \(error)")
        }
    }
    
    func extractNumber(string: String) -> Double {
        let pattern = "\\d+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return 0.0 }
        let range = NSRange(string.startIndex..., in: string)
        var result = 0.0
        
        regex.enumerateMatches(in: string, range: range) { match, _, _ in
            guard
                let matchRange = match?.range,
                let numberRange = Range(matchRange, in: string)
            else { return }
            
            let value = string[numberRange]
            result = Double(String(value)) ?? 0.0
        }
        
        return result
    }
    
    func inputNutrition(portion: Double) {
        homeVM.inputNutrientData(
            calorie: calorie * portion,
            carbs: carbs * portion,
            sugar: sugar * portion,
            protein: protein * portion,
            fat: fat * portion
        )
    }
}
