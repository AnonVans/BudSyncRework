//
//  ContentView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 07/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var signUp = false
    private let localDB = LocalDataManager.shared
    
    var body: some View {
        VStack {
            if signUp {
                SignInView(finishSignUp: $signUp)
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    DataHistoryView()
                        .tabItem {
                            Label("Histroy", systemImage: "document.on.document.fill")
                        }
                    
                    LeaderBoardView()
                        .tabItem {
                            Label("Leaderboard", systemImage: "trophy.fill")
                        }
                }
            }
        }
        .onAppear() {
            let user = localDB.fetchUser()
            signUp = user == nil ? true : false
        }
    }
}

//#Preview {
//    ContentView()
//}
