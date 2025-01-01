//
//  DetailSheetView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct DetailSheetView: View {
    var state: TrackerState
    
    var body: some View {
        VStack(alignment: .leading) {
            if state == .EnergyBurned {
                Text("Active VS Resting Calorie Burn")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)
                
                Text("Active Calorie Burn refers to the energy / calories that you expend during physical activity. \nMeanwhile, Resting Calorie Burn refers to the energy/calories that is expended to keep your body functioning also know as Basal Metabolic Rate (BMR).")
                
                Text("Did You Know?")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)
                
                HStack(alignment: .top) {
                    Text("•")
                        .bold()
                    
                    Text("The majority of an individual calories burn is from the resting calorie burn. Which vary for each individual based on their metabolic rate.")
                        .font(.callout)
                }
                
                HStack(alignment: .top) {
                    Text("•")
                        .bold()
                    
                    Text("Increasing your physical activities can increase your resting calorie burn due to the increase metabolism rate.")
                        .font(.callout)
                }
                
                HStack(alignment: .top) {
                    Text("•")
                        .bold()
                    
                    Text("Resting Calorie Burn increase in relation with amount of muscle / fat free mass.")
                        .font(.callout)
                }
                
                HStack(alignment: .top) {
                    Text("•")
                        .bold()
                    
                    Text("There is no exact recommended value for calorie burn. Especially since, calorie burn can vary depending on an individual's need and target.")
                        .font(.callout)
                }
                
                HStack(alignment: .top) {
                    Text("•")
                        .bold()
                    
                    Text("It is advised to balance your calorie burn or energy expendature with your caloric intake. An inbalance between the two is typically associated with weight gain or loss.")
                        .font(.callout)
                }
            } else {
                Text(state == .Sleep ? "Recommended Sleep Amount" : "Recommended Daily Value")
                    .font(.title2)
                    .bold()
                
                Image(state == .Sleep ? "SleepTable" : "NutrientTable")
                    .resizable()
                    .scaledToFit()
                
                if state == .Nutrient {
                    Text("The recommended nutritional values above are relative reference guide based on the relative caloric intake of 2000 calories. Visit your doctor for more specialize nutritional value needs.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 15)
                }
                
                Text("Did You Know?")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)
                
                if state == .Nutrient {
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("The Recommended Daily Value is a selected value used to help calculate the %DV on products nutritional facts table.")
                            .font(.callout)
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("The %DV is calculate based on how much nutrient in a serving of the product compared with the recommended daily value.")
                            .font(.callout)
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("The Recommended Daily Value is only a general guideline based of the 2000 caloric intake recommendation. Personal nutrional and caloric needs may vary for each individual based on age, gender, activity level, metabolism, and etc.")
                            .font(.callout)
                    }
                } else if state == .Sleep {
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("Sleep duration and quality have a connection to an individual's physical and mental health. Not only that, sleep duration and quality also correlates with mood and cognitive performance.")
                            .font(.callout)
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("Getting too little or too much sleep can be harmful to an individual's health and leads to a variety of health issue.")
                            .font(.callout)
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                            .bold()
                        
                        Text("It is recommended to limit screen time before going to bed. The blue light emitted from screens can disrupt sleep patterns and lead to sleep disturbances.")
                            .font(.callout)
                    }
                }
            }
        }
        .padding(.horizontal, 25)
    }
}

#Preview {
    DetailSheetView(state: .EnergyBurned)
}
