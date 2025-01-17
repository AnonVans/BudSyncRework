//
//  ProfileCardView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct ProfileCardView: View {
    @ObservedObject var homeVM = HomeViewModel.shared
    
    var body: some View {
        HStack {
            Image(uiImage: homeVM.profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .padding(.vertical)
            
            Text(homeVM.currUser.username)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 150, alignment: .leading)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.leading, 5)
                .foregroundStyle(.black)
            
            Spacer()
            
            ZStack {
                Image("StreakFlower")
                    .resizable()
                    .foregroundStyle(.red)
                    .frame(width: 70, height: 70)
                
                Text(String(homeVM.streakCount))
                    .font(.title)
                    .bold()
                    .padding(.top, 5)
                    .foregroundStyle(.textGrey)
            }
        }
        .padding(.horizontal, 30)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.bg2)
                .frame(height: 100)
                .opacity(0.75)
                .padding(.horizontal, 15)
        }
    }
}

//#Preview {
//    ProfileCardView()
//}
