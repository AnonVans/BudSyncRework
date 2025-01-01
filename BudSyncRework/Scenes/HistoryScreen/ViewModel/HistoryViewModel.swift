//
//  HistoryViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var historyData = [HistoricalData]()
    @Published var dataTotal = 0.0
    @Published var isLoading = false
    
    private let healthMng = HealthKitManager.shared
    
    func fetchHistoricalData(type: HealthType, start: Date, end: Date) {
        isLoading = true
        Task {
            switch type {
                case .SleepTime:
                    let data = await healthMng.fetchHistoricalSleepTimeInSec(startdate: start, endDate: end)
                    DispatchQueue.main.async {
                        self.historyData = data
                    }
                default:
                    let data = await healthMng.fetchQuantityTypeHistoricalData(startdate: start, endDate: end, type: type)
                    DispatchQueue.main.async {
                        self.historyData = data
                    }
            }
            
            DispatchQueue.main.async {
                self.calculateTotalData()
                self.isLoading = false
            }
        }
    }
    
    func calculateTotalData() {
        dataTotal = 0.0
        for data in historyData {
            dataTotal += data.value
        }
    }
    
    func dummyData() {
        let calendar = Calendar(identifier: .gregorian)
        let dateOri = calendar.startOfDay(for: Date())
        historyData = [
            HistoricalData(date: dateOri, value: 10.0),
            HistoricalData(date: calendar.date(byAdding: .day, value: -1, to: dateOri)!, value: 10.0),
            HistoricalData(date: calendar.date(byAdding: .day, value: -2, to: dateOri)!, value: 20.0),
            HistoricalData(date: calendar.date(byAdding: .day, value: -3, to: dateOri)!, value: 50.5),
            HistoricalData(date: calendar.date(byAdding: .day, value: -4, to: dateOri)!, value: 30.0),
            HistoricalData(date: calendar.date(byAdding: .day, value: -5, to: dateOri)!, value: 40.0),
            HistoricalData(date: calendar.date(byAdding: .day, value: -6, to: dateOri)!, value: 15.0)
        ].reversed()
        
        calculateTotalData()
    }
}
