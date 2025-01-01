//
//  FriendViewModel.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 15/12/24.
//

import Foundation
import SwiftUI

class FriendViewModel {
    private let localDB = LocalDataManager.shared
    private let cloudDB = CloudKitManager.shared
    
    func generateQRCode() -> UIImage {
        guard
            let user = localDB.fetchUser(),
            let idData = user.userID.data(using: .utf8),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return UIImage(systemName: "exclamationmark.triangle.fill")! }
        
        filter.setValue(idData, forKey: "inputMessage")
        
        guard
            let qrImage = filter.outputImage
        else { return UIImage(systemName: "exclamationmark.triangle.fill")! }
        
        let scale = CGAffineTransform(scaleX: 10, y: 10)
        let qrCode = qrImage.transformed(by: scale)
        
        if let friendInviteQR = CIContext().createCGImage(qrCode, from: qrCode.extent) {
            return UIImage(cgImage: friendInviteQR)
        } else {
            return UIImage(systemName: "exclamationmark.triangle.fill")!
        }
    }
    
    func addNewFriend(friendID: String) async -> Bool {
        guard let user = localDB.fetchUser() else { return false }
        return await cloudDB.addFriends(userID: user.userID, friendID: friendID)
    }
}
