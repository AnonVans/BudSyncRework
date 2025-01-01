//
//  HistoricalDataDTO.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 20/11/24.
//

import Foundation

struct HistoricalData: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var value: Double
}
