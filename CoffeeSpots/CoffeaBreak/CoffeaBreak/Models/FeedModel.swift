//
//  FeedModel.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import Foundation
import CoreLocation

// Identifiable lets SwiftUI track each spot in a list by its unique id
// Equatable lets us compare two spots to check if they're the same
struct CafeSpot: Identifiable, Equatable {
    let id: UUID           // unique identifier for each spot
    let name: String       // cafe name
    let location: CodableCoordinates?  // GPS coordinates, optional since not every spot has them
    let locationName: String?          // human readable location e.g. "Blue Bottle, San Francisco"
    let imageName: String  // name reference for the image
    let rating: Double     // user rating 0-10
    let notes: String      // user's notes about the spot
    var imageData: Data?   // raw photo bytes, var because it gets loaded separately after fetch

    // Nested struct to store coordinates in a way that can be saved to JSON (Codable)
    // CLLocationCoordinate2D from CoreLocation can't be encoded directly, so we wrap it
    struct CodableCoordinates: Codable, Equatable {
        let latitude: Double
        let longitude: Double
    }

    // Two spots are considered equal if they share the same id
    // SwiftUI uses this to know which cards to re-render when the list changes
    static func == (lhs: CafeSpot, rhs: CafeSpot) -> Bool {
        lhs.id == rhs.id
    }
}

// Codable conformance is written manually so we can exclude imageData
// imageData is too large to cache to disk as JSON — it gets loaded separately from CloudKit
extension CafeSpot: Codable {

    // Defines which properties get encoded/decoded and what keys they use in JSON
    enum CodingKeys: String, CodingKey {
        case id, name, location, locationName, imageName, rating, notes
    }

    // Called when reading a CafeSpot from JSON (e.g. loading from disk cache)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        // decodeIfPresent means it won't crash if the field is missing in the JSON
        location = try c.decodeIfPresent(CodableCoordinates.self, forKey: .location)
        locationName = try c.decodeIfPresent(String.self, forKey: .locationName)
        imageName = try c.decode(String.self, forKey: .imageName)
        rating = try c.decode(Double.self, forKey: .rating)
        notes = try c.decode(String.self, forKey: .notes)
        // imageData is always nil when loading from cache — fetched separately from CloudKit
        imageData = nil
    }

    // Called when writing a CafeSpot to JSON (e.g. saving to disk cache)
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        // encodeIfPresent skips the field entirely if the value is nil
        try c.encodeIfPresent(location, forKey: .location)
        try c.encodeIfPresent(locationName, forKey: .locationName)
        try c.encode(imageName, forKey: .imageName)
        try c.encode(rating, forKey: .rating)
        try c.encode(notes, forKey: .notes)
        // imageData intentionally not encoded — too large for JSON cache
    }
}
