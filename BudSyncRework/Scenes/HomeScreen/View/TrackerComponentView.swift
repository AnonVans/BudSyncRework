//
//  TrackerView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct TrackerComponentView: View {
    var imageName: String
    var textContent: String
    var color: Color
    var frameHeightInner: Double
    var lineWidth: Double
    var progress: Double
    
    @State var showImage = true
    
    var body: some View {
        ZStack {
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
            
            if showImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .offset(y: imageName == "birthday.cake.fill" ? 0 : lineWidth * 0.5)
                    .frame(width: frameHeightInner - (lineWidth * 2), height: frameHeightInner - (lineWidth * 2))
                    .foregroundStyle(color)
            } else {
                Circle()
                    .frame(height: frameHeightInner + (lineWidth * 3) )
                    .foregroundStyle(.bg)
                    .opacity(0.8)
                
                Text(textContent)
                    .multilineTextAlignment(.center)
                    .bold()
                    .font(frameHeightInner > 100 ? .largeTitle : .title)
                    .foregroundStyle(color)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 1)) {
                showImage.toggle()
            }
        }
    }
}

#Preview {
    TrackerComponentView(
        imageName: TrackerState.Sleep.getStateImage(),
        textContent: "\(10)\nof\n\(30) gr",
        color: Color.gray,
        frameHeightInner: 75,
        lineWidth: 7.5,
        progress: 0.2
    )
}
