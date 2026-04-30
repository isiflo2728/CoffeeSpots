//
//  HomeViewController.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import Foundation

@MainActor
@Observable

class HomeViewModel {
    var spots = [CafeSpot]()
    var errorMessage : String?
    
    private let service = CloudKitService()
    private let cacheKey = "cafeSpots"
    
    func fetchSpots() async {
        do {
            let spots = try await service.fetchFeed()
            self.spots = spots
            saveToCache(spots)
        } catch {
            errorMessage = error.localizedDescription
            print("Fetch failed: \(error)")
            if let cached = loadFromCache() {
                        self.spots = cached
                }
        }
        
    }
    
    private var cacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("\(cacheKey).json")
    }

    private func saveToCache(_ spots: [CafeSpot]) {
        guard let url = cacheURL else { return }
        do {
            let data = try JSONEncoder().encode(spots)
            try data.write(to: url)
        } catch {
            print("Cache write failed: \(error)")
        }
    }

    private func loadFromCache() -> [CafeSpot]? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([CafeSpot].self, from: data)
    }
    
    func save(_ spot: CafeSpot) async {
        do {
            try await service.save(spot)
            await fetchSpots() // refresh after saving
        } catch {
            errorMessage = error.localizedDescription
            print("Save failed: \(error)")
        }
    }
    
}
