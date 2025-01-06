//
//  HealthKitManager.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 20/11/24.
//

import Foundation
import HealthKit

extension HealthType {
    func getTypeId() -> HKQuantityTypeIdentifier {
        switch self {
            case .SleepTime:
                return .dietaryWater
            case .CaloryBurn:
                return .activeEnergyBurned
            case .Protein:
                return .dietaryProtein
            case .Fat:
                return .dietaryFatTotal
            case .Carbs:
                return .dietaryCarbohydrates
            case .CalorieIntake:
                return .dietaryEnergyConsumed
            case .Sugar:
                return .dietarySugar
            }
    }
    
    func getTypeUnit() -> HKUnit {
        switch self {
        case .SleepTime:
            return HKUnit.literUnit(with: .milli)
        case .CaloryBurn:
            return HKUnit.largeCalorie()
        case .Protein:
            return HKUnit.gram()
        case .Fat:
            return HKUnit.gram()
        case .Carbs:
            return HKUnit.gram()
        case .CalorieIntake:
            return HKUnit.largeCalorie()
        case .Sugar:
            return HKUnit.gram()
        }
    }
    
    func getDataType() -> String {
        switch self {
            case .SleepTime:
                return "hr"
            case .CaloryBurn:
                return "kcal"
            default:
                return "gr"
        }
    }
}

class HealthKitManager {
    public static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private let readType: Set = [
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietaryEnergyConsumed)
    ]
    
    private let writeType: Set = [
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietaryEnergyConsumed)
    ]
    
    func requestAuthorization() async {
        do {
            let available = HKHealthStore.isHealthDataAvailable()
            let notDetermine = try await healthStore.statusForAuthorizationRequest(toShare: writeType, read: readType) == .shouldRequest
            
            if available && notDetermine {
                try await healthStore.requestAuthorization(toShare: writeType, read: readType)
            }
        } catch {
            print("Error in healthkit authorization authentication!")
        }
    }
    
    func generateDateRange(sod: Date) -> NSPredicate {
        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: sod)
        
        let trueStart = calendar.date(byAdding: .minute, value: 1, to: startOfDay)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        
        guard
            let startOfNextDay,
            let endOfDay = calendar.date(byAdding: .minute, value: -1, to: startOfNextDay)
        else {
            return HKQuery.predicateForSamples(withStart: trueStart, end: startOfNextDay)
        }
        
        return HKQuery.predicateForSamples(withStart: trueStart, end: endOfDay)
    }
    
    func generateHistoricalRange(sor: Date, eor: Date) -> NSPredicate {
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: sor)
        let endDayStart = calendar.startOfDay(for: eor)
        
        let trueStart = calendar.date(byAdding: .minute, value: 1, to: startDate)
        let startOfAfterEndDay = calendar.date(byAdding: .day, value: 1, to: endDayStart)
        
        guard
            let startOfAfterEndDay,
            let endOfDate = calendar.date(byAdding: .minute, value: -1, to: startOfAfterEndDay)
        else {
            return HKQuery.predicateForSamples(withStart: trueStart, end: startOfAfterEndDay)
        }
        
        return HKQuery.predicateForSamples(withStart: trueStart, end: endOfDate)
    }
    
    func getStartOfDate(sod: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: sod)
        let trueStart = calendar.date(byAdding: .minute, value: 1, to: startDate)
        
        return trueStart ?? startDate
    }
    
    func getEndRangeDate(eor: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let endDayStart = calendar.startOfDay(for: eor)
        let startOfAfterEndDay = calendar.date(byAdding: .day, value: 1, to: endDayStart)
        
        guard
            let startOfAfterEndDay,
            let endOfDate = calendar.date(byAdding: .minute, value: -1, to: startOfAfterEndDay)
        else {
            return eor
        }
        
        return endOfDate
    }
    
    func fetchSleepTimeInSec() async -> Double {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 5
        )
        
        do {
            let results = try await descriptor.result(for: healthStore)
            
            var sleepQuantity = 0.0
            
            let calendar = Calendar(identifier: .gregorian)
            let currDate = calendar.startOfDay(for: Date())
            let startSleepCheck = calendar.date(byAdding: .hour, value: -6, to: currDate) //cek sejak jam 6 sore, hari sebelumnya.
            
            for result in results {
                if result.value == 0 {
                    if result.startDate > startSleepCheck! {
                        let startSleep = result.startDate
                        let endSleep = result.endDate
                        let sleepTime = endSleep.timeIntervalSince(startSleep)
                        sleepQuantity += sleepTime
                    }
                }
            }
            
            return sleepQuantity
        } catch {
            print("Error on fetching data: \(error.localizedDescription)")
        }
        
        return 0.0
    }
    
    func fetchHistoricalSleepTimeInSec(startdate: Date, endDate: Date) async -> [HistoricalData] {
        var returnedData = [HistoricalData]()
        
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 25
        )
        
        do {
            let results = try await descriptor.result(for: healthStore)
            
            let calendar = Calendar(identifier: .gregorian)
            let startRange = calendar.startOfDay(for: startdate)
            let endRange = calendar.startOfDay(for: endDate)
            
            guard
                var endTime = calendar.date(byAdding: .hour, value: 18, to: endRange),
                var startTime = calendar.date(byAdding: .day, value: -1, to: endTime),
                let lastCheck = calendar.date(byAdding: .hour, value: -6, to: startRange)
            else { return returnedData }
            var sleepQuantity = 0.0
            
            for result in results {
                if result.value == 0 && result.startDate >= lastCheck {
                    if result.endDate < endTime && result.startDate > startTime {
                        let startSleep = result.startDate
                        let endSleep = result.endDate
                        let sleepTime = endSleep.timeIntervalSince(startSleep)
                        sleepQuantity += sleepTime
                    } else {
                        let value = sleepQuantity / 3600
                        returnedData.append(HistoricalData(date: calendar.startOfDay(for: endTime), value: value))
                        
                        guard
                            let nextStartTime = calendar.date(byAdding: .day, value: -1, to: startTime),
                            let nextEndTime = calendar.date(byAdding: .day, value: -1, to: endTime)
                        else { continue }
                        
                        startTime = nextStartTime
                        endTime = nextEndTime
                        sleepQuantity = 0.0
                    }
                }
            }
            
            while startTime >= lastCheck {
                let value = sleepQuantity / 3600
                returnedData.append(HistoricalData(date: calendar.startOfDay(for: endTime), value: value))
                
                guard
                    let nextStartTime = calendar.date(byAdding: .day, value: -1, to: startTime),
                    let nextEndTime = calendar.date(byAdding: .day, value: -1, to: endTime)
                else { continue }
                
                startTime = nextStartTime
                endTime = nextEndTime
                sleepQuantity = 0.0
            }
            
        } catch {
            print("Error on fetching historical data: \(error.localizedDescription)")
        }
        
        return returnedData
    }
    
    func fetchQuantityType(type: HealthType) async -> Double {
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: HKQuantityType(type.getTypeId()), predicate: generateDateRange(sod: Date())),
            options: .cumulativeSum
        )
        
        do {
            let results = try await descriptor.result(for: healthStore)
            
            if results != nil {
                let output = results?.sumQuantity()?.doubleValue(for: type.getTypeUnit()) ?? 0
                return output
            }
        } catch {
            print("Error on fetching data: \(error.localizedDescription)")
        }
        
        return 0
    }
    
    func postQuantityType(input: Double, type: HealthType) {
        let curDate = Date()
        let sample = HKQuantitySample(
            type: HKQuantityType(type.getTypeId()),
            quantity: HKQuantity(unit: type.getTypeUnit(), doubleValue: Double(input)),
            start: curDate,
            end: curDate
        )
        
        healthStore.save(sample) { success, error in
            if success {
                print("Successfully added sample to HealthKit at \(Date().formatted())")
            } else {
                print("Error in saving data to HealthKit: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func fetchQuantityTypeHistoricalData(startdate: Date, endDate: Date, type: HealthType) async -> [HistoricalData] {
        var returnedData = [HistoricalData]()
        
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: HKQuantityType(type.getTypeId()), predicate: generateHistoricalRange(sor: startdate, eor: endDate)),
            options: .cumulativeSum,
            anchorDate: getEndRangeDate(eor: endDate),
            intervalComponents: DateComponents(day: 1)
        )
        
        do {
            let results = try await descriptor.result(for: healthStore)
            
            results.enumerateStatistics(from: getStartOfDate(sod: startdate), to: getEndRangeDate(eor: endDate)) { statisticResults, _ in
                let result = statisticResults.sumQuantity()?.doubleValue(for: type.getTypeUnit()) ?? 0.0
                if statisticResults.endDate <= self.getEndRangeDate(eor: endDate) {
                    let newData = HistoricalData(date: self.getStartOfDate(sod: statisticResults.endDate), value: result)
                    returnedData.append(newData)
                }
            }
            
        } catch {
            print("Error fetching historical data: \(error.localizedDescription)")
        }
        
        return returnedData
    }
}
