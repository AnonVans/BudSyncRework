//
//  TrackerView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

enum TrackerState: CaseIterable {
    case Progress
    case Sleep
    case EnergyBurned
    case Nutrient
    
    func getStateImage() -> String {
        switch self {
            case .Progress:
                return "star.fill"
            case .Sleep:
                return "moon.stars.fill"
            case .EnergyBurned:
                return "flame.fill"
            case .Nutrient:
                return "fork.knife"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .Progress:
            return .clear
        case .Sleep:
            return .gray
        case .EnergyBurned:
            return .red
        case .Nutrient:
            return .clear
        }
    }
}

struct TrackerView: View {
    @ObservedObject var homeVM = HomeViewModel.shared
    @Binding var showSheet: Bool
    @Binding var enableInput: Bool
    
    var state: TrackerState
    
    var body: some View {
        switch state {
            case .Progress:
                ZStack {
                    Image(homeVM.currentImage)
                        .resizable()
                        .scaledToFit()
                        .offset(y: 20 * -0.5)
                        .frame(width: 250 - (20 * 2), height: 250 - (20 * 2))
                        .clipShape(Circle())
                    
                    Circle()
                        .stroke(lineWidth: 20)
                        .frame(height: 250 + (20 * 2) )
                        .opacity(0.25)
                        .foregroundStyle(.gray)
                    
                    Circle()
                        .trim(
                            from: 0.0,
                            to: CGFloat(
                                min(homeVM.overallProgress, 1.0)
                            )
                        )
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .frame(height: 250 + (20 * 2))
                        .foregroundStyle(.green)
                        .rotationEffect(.degrees(90))
                }
            case .Sleep:
                ZStack {
                    TrackerComponentView(
                        imageName: state.getStateImage(),
                        textContent: homeVM.getTextInfo(state: .SleepTime),
                        color: state.getColor(),
                        frameHeightInner: 250,
                        lineWidth: 20,
                        progress: homeVM.sleepTimeProgress
                    )
                    
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.gray)
                        .offset(x: 145, y: -145)
                        .onTapGesture {
                            showSheet.toggle()
                        }
                }
            case .EnergyBurned:
                ZStack {
                    TrackerComponentView(
                        imageName: state.getStateImage(),
                        textContent: homeVM.getTextInfo(state: .CaloryBurn),
                        color: state.getColor(),
                        frameHeightInner: 250,
                        lineWidth: 20,
                        progress: homeVM.energyBurnProgress
                    )
                    
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.gray)
                        .offset(x: 145, y: -145)
                        .onTapGesture {
                            showSheet.toggle()
                        }
                }
            case .Nutrient:
                VStack(spacing: 25) {
                    ZStack {
                        TrackerComponentView(
                            imageName: "fork.knife",
                            textContent: homeVM.getTextInfo(state: .CalorieIntake),
                            color: .nutrient,
                            frameHeightInner: 175,
                            lineWidth: 15,
                            progress: homeVM.calorieIntakeProgress
                        )
                        
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.gray)
                            .offset(x: 125, y: -125)
                            .onTapGesture {
                                showSheet.toggle()
                            }
                    }
                    
                    HStack(spacing: 100) {
                        TrackerComponentView(
                            imageName: "fish.fill",
                            textContent: homeVM.getTextInfo(state: .Protein),
                            color: .brown,
                            frameHeightInner: 75,
                            lineWidth: 7.5,
                            progress: homeVM.proteinProgress
                        )
                        
                        TrackerComponentView(
                            imageName: "drop.fill",
                            textContent: homeVM.getTextInfo(state: .Fat),
                            color: .yellow,
                            frameHeightInner: 75,
                            lineWidth: 7.5,
                            progress: homeVM.fatProgress
                        )
                    }
                    
                    HStack(spacing: 100) {
                        TrackerComponentView(
                            imageName: "takeoutbag.and.cup.and.straw.fill",
                            textContent: homeVM.getTextInfo(state: .Carbs),
                            color: .orange,
                            frameHeightInner: 75,
                            lineWidth: 7.5,
                            progress: homeVM.carbsProgress
                        )
                        
                        TrackerComponentView(
                            imageName: "birthday.cake.fill",
                            textContent: homeVM.getTextInfo(state: .Sugar),
                            color: .mint,
                            frameHeightInner: 75,
                            lineWidth: 7.5,
                            progress: homeVM.sugarProgress
                        )
                    }
                    
                    Button {
                        enableInput.toggle()
                    } label: {
                        Text("Save")
                            .bold()
                            .frame(width: 100, height: 35)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
        }
    }
}

//#Preview {
//    TrackerView(state: .Nutrient)
//}
