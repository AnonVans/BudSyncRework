////
////  KeyChainManager.swift
////  BudSyncRework
////
////  Created by Stevans Calvin Candra on 25/12/24.
////
//
//import Foundation
//import Security
//
//#warning("Might be deprecated")
//class KeyChainManager {
//    let service = "com.securestore.budsyncAPIKey"
//    let account = "budsyncAPIKey"
//    
//    func save(key: String) -> Bool {
//        guard let data = key.data(using: .utf8) else {
//            print("Failed to convert key to data")
//            return false
//        }
//        
//        let query: [String: Any] = [
//            kSecClass as String          : kSecClassGenericPassword,
//            kSecAttrService as String    : service,
//            kSecAttrAccount as String    : account,
//            kSecValueData as String      : data,
//            kSecAttrAccessible as String : kSecAttrAccessibleWhenUnlockedThisDeviceOnly
//        ]
//        
//        SecItemDelete(query as CFDictionary)
//        
//        let status = SecItemAdd(query as CFDictionary, nil)
//        return status == errSecSuccess
//    }
//    
//    func fetchKey(completion: @escaping (String?) -> Void) {
//        let query: [String: Any] = [
//            kSecClass as String       : kSecClassGenericPassword,
//            kSecAttrService as String : service,
//            kSecAttrAccount as String : account,
//            kSecReturnData as String  : true,
//            kSecAttrAccessible as String : kSecAttrAccessibleWhenUnlockedThisDeviceOnly
//        ]
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            var dataTypeRef: AnyObject?
//            
//            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
//            if status == errSecSuccess {
//                guard let data = dataTypeRef as? Data else {
//                    DispatchQueue.main.async {
//                        completion(nil)
//                    }
//                    
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    completion(String(data: data, encoding: .utf8))
//                }
//            } else {
//                print("Keychain read failed with status: \(status)")
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }
//    }
//    
//    func deleteKey() -> Bool {
//        let query: [String: Any] = [
//            kSecClass as String       : kSecClassGenericPassword,
//            kSecAttrService as String : service,
//            kSecAttrAccount as String : account
//        ]
//        
//        let status = SecItemDelete(query as CFDictionary)
//        return status == errSecSuccess || status == errSecItemNotFound
//    }
//}
