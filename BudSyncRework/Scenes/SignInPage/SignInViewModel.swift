//
//  SignInViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 12/12/24.
//

import Foundation
import AuthenticationServices

class SignInViewModel {
    private let localDataManager = LocalDataManager.shared
    private let cloudKitManager = CloudKitManager.shared
    
    func handleSignInAuthorization(authorization: ASAuthorization) async {
        if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard
                let email = appleCredential.email,
                let username = appleCredential.fullName
            else {
                return
            }
            
            let first = username.givenName ?? ""
            let middle = username.middleName ?? ""
            let last = username.familyName ?? ""
            let name = first + " " + middle + " " + last
            
            let newUser = LocalUserEntity(
                email: email,
                username: name
            )
            await newUserSignUp(newUser: newUser)
        }
    }
    
    func newUserSignUp(newUser: LocalUserEntity) async {
        var userData = newUser
        
        do {
            let id = try await cloudKitManager.saveData(user: LeaderBoardDataEntity(
                id: "",
                profileImage: UIImage(systemName: "person.crop.circle.fill"),
                username: userData.username,
                email: userData.email,
                score: 0,
                friendList: [String]()
            ))
            
            userData.userID = id
            localDataManager.saveUser(userData: userData)
        } catch {
            print("failed saving new user")
        }
    }
}
