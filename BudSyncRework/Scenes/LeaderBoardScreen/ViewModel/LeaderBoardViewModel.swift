//
//  LeaderBoardViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 19/12/24.
//

import Foundation

class LeaderBoardViewModel: ObservableObject {
    @Published var displayItems: [LeaderBoardDataEntity] = []
    
    private let localDB = LocalDataManager.shared
    private let cloudDB = CloudKitManager.shared
    
    init() {
        fetchLeaderBoardItem()
    }
    
    func fetchLeaderBoardItem() {
        Task {
            var userID = ""
            
            guard let localUser = localDB.fetchUser() else { return }
            userID = localUser.userID
            
            guard
                let publicUser = await cloudDB.fetchUser(id: userID),
                let friendList = publicUser.friendList
            else { return }
            
            if !friendList.isEmpty {
                let leaderBoardItems: [LeaderBoardDataEntity] = await withCheckedContinuation { continuation in
                    self.cloudDB.fetchData(ids: friendList) { returnedItems in
                        guard
                            let items = returnedItems
                        else {
                            print("No Data Found")
                            continuation.resume(returning: [])
                            return
                        }
                        
                        continuation.resume(returning: items)
                    }
                }
                
                DispatchQueue.main.async {
                    self.displayItems = leaderBoardItems
                }
            }
        }
    }
}
