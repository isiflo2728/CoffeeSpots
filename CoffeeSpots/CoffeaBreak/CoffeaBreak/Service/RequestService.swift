//
//  RequestService.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/4/26.
//

import CloudKit

extension  FriendRequest{
    
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "FriendRequest")
        record["UUID"] = id.uuidString
        record["senderID"] = senderID
        record["receiverID"] = receiverID
        record["status"] = status.rawValue
      
        return record
    }
    init(from record : CKRecord) throws {
            print("DEBUG parsing record: \(record.recordID.recordName)")
            print("  UUID: \(record["UUID"] as? String ?? "NIL")")
            print("  senderID: \(record["senderID"] as? String ?? "NIL")")
            print("  receiverID: \(record["receiverID"] as? String ?? "NIL")")
            print("  status: \(record["status"] as? String ?? "Nil")")
                
                guard
                    let idString = record["UUID"] as? String,
                    let id = UUID(uuidString: idString),
                    let senderID = record["senderID"] as? String,
                    let receiverID = record["receiverID"] as? String,
                    let statusRaw = record["status"] as? String,
                    let status = Status(rawValue: statusRaw)
                else {
                    print("DEBUG guard failed — one of the required fields is NIL")
                    throw NSError(domain: "User", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse CKRecord"])
                 }
                
                self.id = id
                self.senderID = senderID
                self.receiverID = receiverID
                self.status = status
        }
       
    
}
