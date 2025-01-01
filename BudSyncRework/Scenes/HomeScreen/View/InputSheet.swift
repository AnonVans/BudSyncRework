//
//  TrackerInputView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct TrackerInputView: View {
    @ObservedObject var nutriInputVM = NutritionTableManager()
    @State var manualInput = true
    @State var portion = 1.0
    @State var inputImage: UIImage?
    @State var cameraInput = false
    @Binding var showInput: Bool
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Calorie (kcal)")
                        .frame(width: 115, alignment: .leading)
                    
                    Text(":")
                        .padding(.leading, -15)
                        .padding(.trailing)
                    
                    TextField(
                        "",
                        value: $nutriInputVM.calorie,
                        format: .number
                    )
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Carbs (gr)")
                        .frame(width: 115, alignment: .leading)
                    
                    Text(":")
                        .padding(.leading, -15)
                        .padding(.trailing)
                    
                    TextField(
                        "",
                        value: $nutriInputVM.carbs,
                        format: .number
                    )
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Sugar (gr)")
                        .frame(width: 115, alignment: .leading)
                    
                    Text(":")
                        .padding(.leading, -15)
                        .padding(.trailing)
                    
                    TextField(
                        "",
                        value: $nutriInputVM.sugar,
                        format: .number
                    )
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Protein (gr)")
                        .frame(width: 115, alignment: .leading)
                    
                    Text(":")
                        .padding(.leading, -15)
                        .padding(.trailing)
                    
                    TextField(
                        "",
                        value: $nutriInputVM.protein,
                        format: .number
                    )
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Fat (gr)")
                        .frame(width: 115, alignment: .leading)
                    
                    Text(":")
                        .padding(.leading, -15)
                        .padding(.trailing)
                    
                    TextField(
                        "",
                        value: $nutriInputVM.fat,
                        format: .number
                    )
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                }
                
                if !manualInput {
                    HStack {
                        Text("Portions")
                            .frame(width: 115, alignment: .leading)
                        
                        Text(":")
                            .padding(.leading, -15)
                            .padding(.trailing)
                        
                        TextField(
                            "",
                            value: $portion,
                            format: .number
                        )
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                    }
                }
            }
            .padding(.horizontal, 60)
            
            HStack {
                Button("Scan Nutrition Table") {
                    manualInput = false
                    cameraInput.toggle()
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                
                Button("Submit") {
                    nutriInputVM.inputNutrition(portion: portion)
                    showInput.toggle()
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding(.vertical, 50)
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .padding(.horizontal, 50)
        .fullScreenCover(isPresented: $cameraInput) {
            ImagePicker(chosenImage: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage) { oldValue, newValue in
            nutriInputVM.scanImage(image: inputImage)
        }
    }
}
