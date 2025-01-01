////
////  SwiftDataManager.swift
////  BudSyncRework
////
////  Created by Stevans Calvin Candra on 21/11/24.
////
//
//import Foundation
//
//class LocalDataManager {
//    static let shared = LocalDataManager()
//    public var container: ModelContainer
//    public var context: ModelContext
//
//    init() {
//        do {
//            self.container = try ModelContainer(
//                for: LocalUserEntity.self,
//                configurations: ModelConfiguration(
//                    isStoredInMemoryOnly: false
//                )
//            )
//            self.context = ModelContext(container)
//        } catch {
//            fatalError("Error initializing database container: \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchUserByEmail(email: String) throws -> LocalUserEntity {
//        var users: [LocalUserEntity]?
//        
//        do {
//            let descriptor = FetchDescriptor<LocalUserEntity>()
//            users = try context.fetch(descriptor)
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//        
//        guard
//            let retrievedUsers = users,
//            let userData = retrievedUsers.first(where: {$0.email == email})
//        else {
//            throw ErrorMessage.NoData
//        }
//        
//        return userData
//    }
//    
//    func fetchCurrentUser() throws -> LocalUserEntity {
//        var users: [LocalUserEntity]?
//        
//        do {
//            let descriptor = FetchDescriptor<LocalUserEntity>()
//            users = try context.fetch(descriptor)
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//        
//        guard
//            let retrievedUsers = users,
//            let userData = retrievedUsers.first(where: {$0.isLoggedIn == true})
//        else {
//            throw ErrorMessage.NoData
//        }
//        
//        return userData
//    }
//    
//    func signNewUser(userData: LocalUserEntity) {
//        context.insert(userData)
//    }
//    
//    func saveChanges(userData: LocalUserEntity) throws {
//        do {
//            let user = try fetchCurrentUser()
//            user.profile = userData.profile
//            user.email = userData.email
//            user.username = userData.username
//            user.score = userData.score
//            user.isLoggedIn = userData.isLoggedIn
//            user.goals = userData.goals
////            user.trackGoals = userData.trackGoals
//            user.startStreak = userData.startStreak
//            user.lastStreak = userData.lastStreak
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
//    func updateScore(score: Int) throws {
//        do {
//            let user = try fetchCurrentUser()
//            user.score = score
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
//    func deleteLocalUser(id: String) throws {
//        do {
//            let user = try fetchCurrentUser()
//            context.delete(user)
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
//    func logIn(user: LocalUserEntity) throws {
//        do {
//            user.isLoggedIn = true
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
//    func logOut() throws {
//        do {
//            let user = try fetchCurrentUser()
//            user.isLoggedIn = false
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
////    func updateTarget(type: HealthType, target: Double) throws {
////        do {
////            let user = try fetchCurrentUser()
////            user.goals[type.rawValue] = target
////            try context.save()
////        } catch {
////            throw ErrorMessage.ProcessFailure
////        }
////    }
////    
////    func updateCustomTracks(track: [String]) throws {
////        do {
////            let user = try fetchCurrentUser()
////            user.trackGoals = track
////            try context.save()
////        } catch {
////            throw ErrorMessage.ProcessFailure
////        }
////    }
//    
//    func updateStartStreak(date: Date) throws {
//        do {
//            let user = try fetchCurrentUser()
//            user.startStreak = date
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//    
//    func updateEndStreak(date: Date) throws {
//        do {
//            let user = try fetchCurrentUser()
//            user.lastStreak = date
//            try context.save()
//        } catch {
//            throw ErrorMessage.ProcessFailure
//        }
//    }
//}
