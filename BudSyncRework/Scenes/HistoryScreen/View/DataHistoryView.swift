//
//  DataHistoryView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI
import Charts

struct DataHistoryView: View {
    @ObservedObject var dataVM = HistoryViewModel()
    @State var startDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -6, to: Date())!
    @State var endDate = Date()
    @State var selectedType = HealthType.SleepTime.rawValue
    @State var temp = "hello"
    
    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Recorded Data")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text(
                            "\(dataVM.dataTotal, format: .number) \(HealthType.getType(stringType: selectedType)?.getDataType() ?? "kcal")"
                        )
                        .font(.largeTitle)
                        .bold()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Select Type:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, -10)
                        
                        Picker("", selection: $selectedType) {
                            ForEach(HealthType.allCases, id: \.rawValue) { type in
                                Text(type.rawValue)
                            }
                        }
                    }
                }
                
                HStack {
                    DatePicker(
                        "",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    
                    Spacer()
                    
                    Text("to")
                    
                    Spacer()
                    
                    DatePicker(
                        "",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                .padding(.horizontal, 25)
                
                Divider()
                    .padding(.vertical, 10)
                
                if !dataVM.isLoading {
                    Chart(dataVM.historyData, id: \.date) { data in
                        BarMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Recorded Data", data.value)
                        )
                    }
                    .frame(height: 200)
                } else {
                    ProgressView()
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("Recorded Entry:")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                
                if !dataVM.isLoading {
                    List(dataVM.historyData) { data in
                        HistoryCardView(data: data, type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn)
                    }
                    .listStyle(.plain)
                } else {
                    ProgressView()
                }
                
            }
            .padding()
            .onChange(of: selectedType) { oldValue, newValue in
                dataVM.fetchHistoricalData(
                    type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                    start: startDate,
                    end: endDate
                )
            }
            .onChange(of: startDate) { oldValue, newValue in
                if startDate > endDate {
                    dataVM.fetchHistoricalData(
                        type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                        start: endDate,
                        end: startDate
                    )
                } else {
                    dataVM.fetchHistoricalData(
                        type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                        start: startDate,
                        end: endDate
                    )
                }
            }
            .onChange(of: endDate) { oldValue, newValue in
                if startDate > endDate {
                    dataVM.fetchHistoricalData(
                        type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                        start: endDate,
                        end: startDate
                    )
                } else {
                    dataVM.fetchHistoricalData(
                        type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                        start: startDate,
                        end: endDate
                    )
                }
            }
        }
        .onAppear {
            let calendar = Calendar(identifier: .gregorian)
            let eor = calendar.startOfDay(for: Date())
            let sor = calendar.date(byAdding: .day, value: -6, to: eor)
            dataVM.fetchHistoricalData(
                type: HealthType.getType(stringType: selectedType) ?? .CaloryBurn,
                start: sor!,
                end: eor
            )
        }
    }
}

#Preview {
    DataHistoryView()
}
