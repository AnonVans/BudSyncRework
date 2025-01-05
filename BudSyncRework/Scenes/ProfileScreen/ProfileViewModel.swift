//
//  ProfileViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    static let shared = ProfileViewModel()
    private let localDB = LocalDataManager.shared
    private let cloudDB = CloudKitManager.shared

    private var defaultUser = LocalUserEntity()
    @Published var currUser = LocalUserEntity()
    @Published var profileImage = UIImage(systemName: "person.crop.circle")!
    @Published var enableSaveChanges = false
    @Published var updateSuccess = false
    
    init() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let user = localDB.fetchUser() else {
            return
        }
        
        currUser = user
        defaultUser = user
        profileImage = currUser.generateImage()
    }
    
    func updateUserProfile(image: UIImage?) {
        guard
            let profile = image?.optimizeScale(),
            let data = profile.jpegData(compressionQuality: 0.8)
        else { return }
        
        profileImage = profile
        currUser.profile = data
    }
    
    func updateUser() async {
        localDB.saveChanges(userData: currUser)
        let result = await cloudDB.updateData(
            user: LeaderBoardDataEntity(
                id: currUser.userID,
                profileImage: currUser.generateImage(),
                username: currUser.username,
                email: currUser.email,
                score: currUser.score,
                friendList: [String]()
            )
        )
        
        DispatchQueue.main.async {
            self.enableSaveChanges = false
            self.updateSuccess = result
        }
    }
    
    func cancelChanges() {
        currUser.email = defaultUser.email
        currUser.username = defaultUser.username
        currUser.profile = defaultUser.profile
        currUser.goals = defaultUser.goals
        
        profileImage = UIImage(data: defaultUser.profile) ?? UIImage(systemName: "person.crop.circle")!
    }
    
    func checkChanges() {
        let email = currUser.email != defaultUser.email
        let username = currUser.username != defaultUser.username
        let profile = currUser.profile   != defaultUser.profile
        let target = currUser.goals != defaultUser.goals
        
        enableSaveChanges = email || username || profile || target
    }
    
    func deleteAccount() async {
        let result = await cloudDB.deleteUser(userID: currUser.userID)
        if result {
            localDB.removeAccount()
        }
    }
}
