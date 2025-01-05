//
//  CloudKitManager.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 21/11/24.
//

import Foundation
import SwiftUI
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    private let container: CKContainer
    private let publicDb: CKDatabase
    private let recordType = "LeaderBoardData"
//    private let keyRecord = "FoodAnalysisKey"
    
    init() {
        self.container = CKContainer.default()
        self.publicDb = container.publicCloudDatabase
    }
    
    func prepareCKAsset(image: UIImage?) -> CKAsset? {
        guard let scaledImage = image?.optimizeScale() else { return nil }
        
        guard
            let url = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )
                .first?
                .appendingPathComponent(
                    "asset#\(UUID.init().uuidString)"
                ),
            let data = scaledImage.jpegData(compressionQuality: 0.8)
        else { return nil }
        
        do {
            try data.write(to: url)
            return CKAsset(fileURL: url)
        } catch {
            print("Error writing asset: \(error)")
        }
        
        return nil
    }
    
    func prepareRecord(user: LeaderBoardDataEntity) -> CKRecord {
        let record = CKRecord(recordType: recordType)
        record.setValue(user.email, forKey: RecordField.Email.rawValue)
        record.setValue(user.username, forKey: RecordField.Username.rawValue)
        record.setValue(user.score, forKey: RecordField.Score.rawValue)
        record.setValue(user.friendList, forKey: RecordField.FriendList.rawValue)
        
        guard let asset = prepareCKAsset(image: user.profileImage) else {
            return record
        }
        record.setValue(asset, forKey: RecordField.ProfileImage.rawValue)
        
        return record
    }
    
    func mapToEntity(record: CKRecord) -> LeaderBoardDataEntity? {
        guard
            let profileAssets = record.value(forKey: RecordField.ProfileImage.rawValue) as? CKAsset,
            let email = record.value(forKey: RecordField.Email.rawValue) as? String,
            let username = record.value(forKey: RecordField.Username.rawValue) as? String,
            let score = record.value(forKey: RecordField.Score.rawValue) as? Int,
            let list = record.value(forKey: RecordField.FriendList.rawValue) as? [String],
            let url = profileAssets.fileURL,
            let data = try? Data(contentsOf: url),
            let profileImage = UIImage(data: data)
        else { return nil }
        
        return LeaderBoardDataEntity(
            id: record.recordID.recordName,
            profileImage: profileImage,
            username: username,
            email: email,
            score: score,
            friendList: list
        )
    }
    
    func saveData(user: LeaderBoardDataEntity) async throws -> String {
        do {
            let record = try await publicDb.save(prepareRecord(user: user))
            return record.recordID.recordName
        } catch {
            print("Failed: \(error.localizedDescription)")
            throw ErrorMessage.ProcessFailure
        }
    }
    
    func fetchUser(id: String) async -> LeaderBoardDataEntity? {
        do {
            let record = try await publicDb.record(for: CKRecord.ID(recordName: id))
            return mapToEntity(record: record)
        } catch {
            print("No User Found")
            return nil
        }
    }
    
    func fetchData(ids: [String], completion: @escaping ([LeaderBoardDataEntity]?) -> Void) {
        var lbData = [LeaderBoardDataEntity]()
        let sod = Calendar(identifier: .gregorian).startOfDay(for: Date())
        
        var recordIDs = [CKRecord.ID]()
        ids.forEach { id in
            recordIDs.append(CKRecord.ID(recordName: id))
        }
        
        let predicate = NSPredicate(format: "recordID IN %@", argumentArray: [recordIDs])
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    guard
                        let dataDate = record.modificationDate,
                        var entity = self.mapToEntity(record: record)
                    else { return }
                
                    if dataDate < sod {
                        entity.score = 0
                    }
                    lbData.append(entity)
                
                case .failure(let error):
                    print("Error fetching data: \(error)")
            }
        }
        
        queryOperation.queryResultBlock = { result in
            switch result {
                case .success:
                    completion(lbData)
                case .failure(let error):
                    print("Error fetching data: \(error)")
            }
        }
        
        publicDb.add(queryOperation)
    }
    
    func updateData(user: LeaderBoardDataEntity) async -> Bool {
        guard let id = user.id else { return false }
        do {
            let record = try await publicDb.record(for: CKRecord.ID(recordName: id))
            record.setValue(user.email, forKey: RecordField.Email.rawValue)
            record.setValue(user.username, forKey: RecordField.Username.rawValue)
            record.setValue(user.score, forKey: RecordField.Score.rawValue)
            
            guard let asset = prepareCKAsset(image: user.profileImage) else {
                try await publicDb.save(record)
                return true
            }
            record.setValue(asset, forKey: RecordField.ProfileImage.rawValue)
            
            try await publicDb.save(record)
            return true
        } catch {
            return false
        }
    }
    
    func updateScore(userID: String, newScr: Int) async -> Bool {
        do {
            let record = try await publicDb.record(for: CKRecord.ID(recordName: userID))
            record.setValue(newScr, forKey: RecordField.Score.rawValue)
            
            try await publicDb.save(record)
            return true
        } catch {
            return false
        }
    }
    
    func updateFriendList(user: LeaderBoardDataEntity) async -> Bool {
        guard let id = user.id else { return false }
        do {
            let record = try await publicDb.record(for: CKRecord.ID(recordName: id))
            record.setValue(user.friendList, forKey: RecordField.FriendList.rawValue)
            
            try await publicDb.save(record)
            return true
        } catch {
            return false
        }
    }
    
    func deleteUser(userID: String) async -> Bool {
        do {
            guard
                let user = await fetchUser(id: userID),
                let friends = user.friendList
            else { return false }
            
            if !friends.isEmpty {
                for friend in friends {
                    let record = try await publicDb.record(for: CKRecord.ID(recordName: friend))
                    var list = record.value(forKey: RecordField.FriendList.rawValue) as? [String]
                    list?.removeAll { $0 == userID }
                    record.setValue(list, forKey: RecordField.FriendList.rawValue)
                    try await publicDb.save(record)
                }
            }
            
            try await publicDb.deleteRecord(withID: CKRecord.ID(recordName: userID))
            return true
        } catch {
            return false
        }
    }
    
    func addFriends(userID: String, friendID: String) async -> Bool {
        do {
            let recordSelf = try await publicDb.record(for: CKRecord.ID(recordName: userID))
            let recordFriend = try await publicDb.record(for: CKRecord.ID(recordName: friendID))
            
            guard
                var selfUser = mapToEntity(record: recordSelf),
                var friendUser = mapToEntity(record: recordFriend),
                let listSelf = selfUser.friendList,
                let listFriend = friendUser.friendList
            else {
                return false }
            
            if !listSelf.contains(friendID) {
                selfUser.friendList?.append(friendID)
                _ = await updateFriendList(user: selfUser)
            }
            
            if !listFriend.contains(userID) {
                friendUser.friendList?.append(userID)
                _ = await updateFriendList(user: friendUser)
            }
            
            return true
        } catch {
            return false
        }
    }
}
