//
//  LeaderBoardView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 19/12/24.
//

import SwiftUI

struct LeaderBoardView: View {
    @ObservedObject private var leaderBoardVM = LeaderBoardViewModel()
    @State var showToast = false
    @State var actionResult: Bool? = false
    @State var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg
                    .ignoresSafeArea()
                
                VStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.brown)
                        .opacity(0.5)
                        .frame(width: 250, height: 50)
                        .overlay {
                            Text("Leader Board")
                                .font(.title)
                                .bold()
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.brown, style: StrokeStyle(lineWidth: 5))
                        }
                        .padding(.bottom, 10)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.green)
                            .opacity(0.5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                            }
                        
                        ScrollView {
                            VStack(spacing: 12.5) {
                                if leaderBoardVM.displayItems.isEmpty {
                                    Text("No Friends To Display")
                                } else {
                                    ForEach(leaderBoardVM.displayItems, id: \.self) { item in
                                        ListCardView(userItem: item)
                                    }
                                }
                            }
                            .padding(.top, 17.5)
                            .padding(.horizontal, 25)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .frame(width: 350, height: 550)
                }
                
                if showToast {
                    if actionResult == true {
                        ToastView(
                            message: "Successfully add new friend",
                            success: true
                        )
                    } else if actionResult == false {
                        ToastView(
                            message: "Failed adding new friend",
                            success: false
                        )
                    }
                }
            }
            .navigationTitle("Leader Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Add Friend") {
                        AddFriendView(
                            actionResult: $actionResult,
                            showAlert: $showToast
                        )
                    }
                }
            }
            .onChange(of: showToast) { oldValue, newValue in
                if showToast {
                    timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 1)) {
                            showToast = false
                            leaderBoardVM.fetchLeaderBoardItem()
                        }
                        timer?.invalidate()
                        timer = nil
                    }
                }
            }
        }
        .refreshable {
            leaderBoardVM.fetchLeaderBoardItem()
        }
    }
}

#Preview {
    LeaderBoardView()
}
