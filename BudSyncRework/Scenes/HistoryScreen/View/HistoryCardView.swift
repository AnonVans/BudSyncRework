//
//  HistoryCardView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct HistoryCardView: View {
    var data: HistoricalData
    var type: HealthType
    
    var body: some View {
        HStack {
            Text(data.date.formatted(date: .abbreviated, time: .omitted))
            
            Spacer()
            
            Text("\(data.value, format: .number) \(type.getDataType())")
        }
        .font(.callout)
        .fontWeight(.semibold)
    }
}

#Preview {
    HistoryCardView(data: HistoricalData(date: Date(), value: 25.0), type: .CaloryBurn)
}
