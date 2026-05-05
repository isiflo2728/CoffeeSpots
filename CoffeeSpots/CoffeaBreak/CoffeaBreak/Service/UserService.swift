//
//  UserService.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/4/26.
//

import CloudKit

extension UserModel {
    
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType : "User")
        
        record["UUID"] = id.uuidString
        record["userName"] = userName
        record["displayName"] = displayName
        
        if let bio {record["bio"] = bio }
        
        if let imageData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(id.uuidString
                                                                                        + ".jpg")
            try? imageData.write(to: tempURL)
            record["image"] = CKAsset(fileURL: tempURL)
        }
        return record
        
    }
    
    init(from record: CKRecord) throws {
        print("DEBUG parsing record: \(record.recordID.recordName)")
        print("  UUID: \(record["UUID"] as? String ?? "NIL")")
        print("  userName: \(record["userName"] as? String ?? "NIL")")
        print("  displayName: \(record["displayName"] as? String ?? "NIL")")
        
        guard
            let idString = record["UUID"] as? String,
            let id = UUID(uuidString: idString),
            let userName = record["userName"] as? String,
            let displayName = record["displayName"] as? String
           
        else {
            print("DEBUG guard failed — one of the required fields is NIL")
            throw NSError(domain: "User", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse CKRecord"])
        }
        
        self.id = id
        self.userName = userName
        self.displayName = displayName
        self.bio = record["bio"] as String?
        
        if let imageAsset = record["image"] as? CKAsset,
           let fileURL = imageAsset.fileURL,
        let data = try? Data(contentsOf: fileURL){
            self.imageData = data
            
        }else{
            self.imageData = nil
        }
        self.cloudKitRecordID = record.recordID
  
    }
}

class UserService {
    private let container = CKContainer(identifier: "iCloud.com.isidoro.CafeSpots")
    private var database : CKDatabase{container.publicCloudDatabase}

    
    func save(_ spot: UserModel) async throws {
        let iCloudID = try await container.userRecordID().recordName
        let record = spot.toRecord()
        record["iCloudID"] = iCloudID
        try await database.save(record)
    }

    func fetchCurrentUser() async throws -> UserModel {
        let iCloudID = try await container.userRecordID().recordName
        let predicate = NSPredicate(format: "iCloudID == %@", iCloudID)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let (results, _) = try await database.records(matching: query, resultsLimit: 1)

        guard let firstResult = results.first,
              let record = try? firstResult.1.get() else {
            throw NSError(domain: "User", code: 404, userInfo: [NSLocalizedDescriptionKey: "No user profile found"])
        }

        return try UserModel(from: record)
    }
    
    func searchUser(username: String) async throws -> [UserModel]{
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "userName == %@", username))
        query.sortDescriptors = [NSSortDescriptor(key: "userName", ascending: true)]
        
        let (results, _) = try await database.records(matching: query)
        
        return results.compactMap{ _, result in
            do{
                let record = try result.get()
                return try UserModel(from: record)
            } catch {
                print("Failed to parse record \(error)")
                return nil
            }
        }
    }
    
    func sendFreindRequest(to user: UserModel) async throws{
        let receiverID = user.id.uuidString
        let senderID = try await container.userRecordID().recordName
        
        let friendRequest = FriendRequest(id : UUID(), senderID: senderID, receiverID: receiverID, status: .pending)
        
        let record = friendRequest.toRecord()
        try await database.save(record)
        
    }
    
    func updateStatus(of request: FriendRequest, to newStatus: FriendRequest.Status) async throws{
        let recordID = CKRecord.ID(recordName: request.id.uuidString)
        let record = try await database.record(for : recordID)
        
        record["status"] = newStatus.rawValue
        
        _ = try await database.save(record)
    }
   
}
    

