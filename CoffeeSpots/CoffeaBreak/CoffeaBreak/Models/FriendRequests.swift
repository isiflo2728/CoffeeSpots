//
//  FriendRequests.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/4/26.
//

import Foundation
import CloudKit

struct FriendRequest: Codable {
    let id : UUID
    let senderID : String
    let receiverID : String
    let status : Status
    
    enum Status:String, Codable {
        case pending, accepted, denied
    }
}
