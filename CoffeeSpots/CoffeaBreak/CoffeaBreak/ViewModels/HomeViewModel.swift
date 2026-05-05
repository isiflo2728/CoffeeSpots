//
//  HomeViewController.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import Foundation
import SwiftUI

// Ensures all property updates happen on the main thread so SwiftUI re-renders correctly
@MainActor
// Tells SwiftUI to automatically track changes to this class's properties
@Observable

class HomeViewModel {
    // The list of cafe spots displayed in the feed
    var spots = [CafeSpot]()
    // Holds an error message to show the user if something goes wrong
    var errorMessage: String?

    // The object that talks to CloudKit (fetch and save)
    private let service = CloudKitService()
    // The filename used when writing spots to disk cache
    private let cacheKey = "cafeSpots"

    // Fetches spots from CloudKit and updates the feed
    func fetchSpots() async {
        do {
            // Ask CloudKit for all spots
            let spots = try await service.fetchFeed()
            // Update the feed so the UI refreshes
            self.spots = spots
            // Write the fresh data to disk so it's available offline next time
            saveToCache(spots)
        } catch {
            // Store the error so the UI can show it
            errorMessage = error.localizedDescription
            print("Fetch failed: \(error)")
            // CloudKit failed — fall back to whatever we last saved to disk
            if let cached = loadFromCache() {
                self.spots = cached
            }
        }
    }

    // Builds the file URL where the cached JSON is stored on disk
    private var cacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("\(cacheKey).json")
    }

    // Encodes the spots array to JSON and writes it to disk
    private func saveToCache(_ spots: [CafeSpot]) {
        guard let url = cacheURL else { return }
        do {
            let data = try JSONEncoder().encode(spots)
            try data.write(to: url)
        } catch {
            print("Cache write failed: \(error)")
        }
    }

    // Reads the cached JSON from disk and decodes it back into CafeSpot objects
    private func loadFromCache() -> [CafeSpot]? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([CafeSpot].self, from: data)
    }

    // Saves a new spot to CloudKit then refreshes the feed to include it
    func save(_ spot: CafeSpot) async {
        do {
            try await service.save(spot)
            await fetchSpots()
        } catch {
            errorMessage = error.localizedDescription
            print("Save failed: \(error)")
        }
    }

    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let spot = spots[index]
            do {
                try await service.deleteSpot(of: spot)
            } catch {
                errorMessage = error.localizedDescription
                print("Delete failed: \(error)")
            }
        }
        spots.remove(atOffsets: offsets)
    }

}
