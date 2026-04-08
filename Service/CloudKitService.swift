//
//  CloudKitService.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import CloudKit

extension CafeSpot {
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "CafeSpot")

        record["UUID"] = id.uuidString
        record["name"] = name
        record["imageName"] = imageName
        record["rating"] = rating
        record["notes"] = notes
        if let locationName { record["locationName"] = locationName }

        if let imageData {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(id.uuidString + ".jpg")
            try? imageData.write(to: tempURL)
            record["image"] = CKAsset(fileURL: tempURL)
        }

        if let location {
            record["latitude"] = location.latitude
            record["longitude"] = location.longitude
        }

        return record
    }

    init(from record: CKRecord) throws {
        guard
            let idString = record["UUID"] as? String,
            let id = UUID(uuidString: idString),
            let name = record["name"] as? String,
            let imageName = record["imageName"] as? String,
            let rating = record["rating"] as? Double,
            let notes = record["notes"] as? String
        else {
            throw NSError(domain: "CafeSpot", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse CKRecord"])
        }

        self.id = id
        self.name = name
        self.imageName = imageName
        self.rating = rating
        self.notes = notes
        self.locationName = record["locationName"] as? String

        if let lat = record["latitude"] as? Double,
           let lon = record["longitude"] as? Double {
            self.location = CodableCoordinates(latitude: lat, longitude: lon)
        } else {
            self.location = nil
        }

        if let asset = record["image"] as? CKAsset,
           let fileURL = asset.fileURL,
           let data = try? Data(contentsOf: fileURL) {
            self.imageData = data
        } else {
            self.imageData = nil
        }
    }
}

class CloudKitService {
    private let database = CKContainer.default().publicCloudDatabase

    func save(_ spot: CafeSpot) async throws {
        let record = spot.toRecord()
        try await database.save(record)
    }

    func fetchFeed() async throws -> [CafeSpot] {
        let query = CKQuery(recordType: "CafeSpot", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let (results, _) = try await database.records(matching: query)

        return results.compactMap { _, result in
            do {
                let record = try result.get()
                return try CafeSpot(from: record)
            } catch {
                print("Failed to parse record: \(error)")
                return nil
            }
        }
    }
}
