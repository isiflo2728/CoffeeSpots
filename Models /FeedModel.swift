//
//  FeedModel.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import Foundation
import CoreLocation

struct CafeSpot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let location: CodableCoordinates?
    let locationName: String?
    let imageName: String
    let rating: Double
    let notes: String
    var imageData: Data?

    struct CodableCoordinates: Codable, Equatable {
        let latitude: Double
        let longitude: Double
    }

    static func == (lhs: CafeSpot, rhs: CafeSpot) -> Bool {
        lhs.id == rhs.id
    }
}

// Codable excludes imageData — too large to cache
extension CafeSpot: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, location, locationName, imageName, rating, notes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        location = try c.decodeIfPresent(CodableCoordinates.self, forKey: .location)
        locationName = try c.decodeIfPresent(String.self, forKey: .locationName)
        imageName = try c.decode(String.self, forKey: .imageName)
        rating = try c.decode(Double.self, forKey: .rating)
        notes = try c.decode(String.self, forKey: .notes)
        imageData = nil
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(location, forKey: .location)
        try c.encodeIfPresent(locationName, forKey: .locationName)
        try c.encode(imageName, forKey: .imageName)
        try c.encode(rating, forKey: .rating)
        try c.encode(notes, forKey: .notes)
    }
}
