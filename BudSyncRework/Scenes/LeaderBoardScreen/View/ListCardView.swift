//
//  ListCardView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 19/12/24.
//

import SwiftUI

struct ListCardView: View {
    var userItem: LeaderBoardDataEntity
    
    var body: some View {
        HStack {
            Image(uiImage: userItem.profileImage ?? UIImage(systemName: "person.crop.circle")!)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding(.vertical)
            
            Text(userItem.username ?? "Unknown")
                .font(.title3)
                .bold()
                .padding(.horizontal, 10)
            
            Spacer()
            
            Text(String(userItem.score ?? 0))
                .font(.title3)
                .bold()
        }
        .frame(height: 50)
    }
}

#Preview {
    ListCardView(userItem: LeaderBoardDataEntity())
}
