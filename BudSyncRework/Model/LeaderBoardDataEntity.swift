//
//  LeaderBoardDataEntity.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 07/12/24.
//

import Foundation
import SwiftUI

enum RecordField: String {
    case ProfileImage = "ProfileImage"
    case Username = "Username"
    case Email = "Email"
    case Score = "Score"
    case FriendList = "FriendList"
}

struct LeaderBoardDataEntity: Hashable {
    var id: String?
    var profileImage: UIImage?
    var username: String?
    var email: String?
    var score: Int?
    var friendList: [String]?
}
