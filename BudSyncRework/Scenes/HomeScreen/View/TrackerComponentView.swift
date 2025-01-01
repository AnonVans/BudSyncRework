//
//  TrackerView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct TrackerComponentView: View {
    var imageName: String
    var color: Color
    var frameHeightInner: Double
    var lineWidth: Double
    var progress: Double
    
    var body: some View {
        ZStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .offset(y: imageName == "birthday.cake.fill" ? 0 : lineWidth * 0.5)
                .frame(width: frameHeightInner - (lineWidth * 2), height: frameHeightInner - (lineWidth * 2))
                .foregroundStyle(color)
            
            Circle()
                .trim(from: 0.0, to: 0.8)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .frame(height: frameHeightInner + (lineWidth * 2) )
                .opacity(0.25)
                .foregroundStyle(.gray)
                .rotationEffect(.degrees(126))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 0.8)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .frame(height: frameHeightInner + (lineWidth * 2))
                .foregroundStyle(color)
                .rotationEffect(.degrees(126))
        }
    }
}

#Preview {
    TrackerComponentView(
        imageName: TrackerState.Sleep.getStateImage(),
        color: .gray,
        frameHeightInner: 250,
        lineWidth: 20,
        progress: 0.2
    )
}
