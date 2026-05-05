//
//  UserModel.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/2/26.
//

import Foundation
import CloudKit

struct UserModel : Identifiable, Equatable{
    let id : UUID
    let userName : String
    let displayName: String
    let bio : String?
    var imageData : Data?
    let cloudKitRecordID : CKRecord.ID?
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return rhs.id == lhs.id
    }
}

extension UserModel : Codable {
    
    enum CodingKeys : String , CodingKey {
      case id, userName, displayName, bio
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userName = try container.decode(String.self, forKey: .userName)
        displayName = try container.decode(String.self, forKey: .displayName)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        
        imageData = nil
        cloudKitRecordID = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userName, forKey: .userName)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(bio, forKey: .bio)
        // image and cloukit user record inteentionally not encoded because itll be too much to cache
    }
    
    
    
}
