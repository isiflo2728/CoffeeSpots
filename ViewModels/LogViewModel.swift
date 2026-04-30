//
//  LogViewModel.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/8/26.
//

import Foundation
import PhotosUI
import MapKit
import ImageIO
import CoreLocation
import _PhotosUI_SwiftUI

@MainActor
@Observable
final class LogViewModel {

    // MARK: - Form State

    var name = ""
    var rating = 7.0
    var notes = ""
    var imageData: Data?
    var selectedPhoto: PhotosPickerItem?
    var location: CafeSpot.CodableCoordinates?
    var locationName = ""
    var locationFromPhoto = false
    var locationQuery = ""
    var searchResults: [MKMapItem] = []

    // MARK: - UI Feedback

    var isSaving = false
    var showConfirmation = false
    var savedSpotName = ""

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Dependencies

    private let homeViewModel: HomeViewModel

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }

    // MARK: - Photo

    func handlePhotoSelection() async {
        guard let data = try? await selectedPhoto?.loadTransferable(type: Data.self) else { return }
        imageData = data
        if let coords = extractCoordinates(from: data) {
            location = coords
            locationFromPhoto = true
            locationName = await reverseGeocode(coords)
        }
    }

    func removePhoto() {
        imageData = nil
        if locationFromPhoto {
            removeLocation()
        }
    }

    // MARK: - Location

    func searchLocations() async {
        guard !locationQuery.isEmpty else { searchResults = []; return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationQuery
        let response = try? await MKLocalSearch(request: request).start()
        searchResults = response?.mapItems ?? []
    }

    func selectLocation(_ item: MKMapItem) {
        location = CafeSpot.CodableCoordinates(
            latitude: item.placemark.coordinate.latitude,
            longitude: item.placemark.coordinate.longitude
        )
        locationName = item.name ?? ""
        locationQuery = ""
        searchResults = []
    }

    func removeLocation() {
        location = nil
        locationName = ""
        locationFromPhoto = false
    }

    // MARK: - Save

    func save() async {
        isSaving = true
        savedSpotName = name.trimmingCharacters(in: .whitespaces)
        let spot = CafeSpot(
            id: UUID(),
            name: savedSpotName,
            location: location,
            locationName: locationName.isEmpty ? nil : locationName,
            imageName: "",
            rating: rating,
            notes: notes.trimmingCharacters(in: .whitespaces),
            imageData: imageData
        )
        await homeViewModel.save(spot)
        isSaving = false
        showConfirmation = true
    }

    func resetForm() {
        name = ""
        rating = 7.0
        notes = ""
        imageData = nil
        selectedPhoto = nil
        location = nil
        locationName = ""
        locationFromPhoto = false
        locationQuery = ""
        searchResults = []
    }

    // MARK: - Private Helpers

    private func extractCoordinates(from data: Data) -> CafeSpot.CodableCoordinates? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gps = props[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
              let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String
        else { return nil }

        return CafeSpot.CodableCoordinates(
            latitude: latRef == "S" ? -lat : lat,
            longitude: lonRef == "W" ? -lon : lon
        )
    }

    private func reverseGeocode(_ coords: CafeSpot.CodableCoordinates) async -> String {
        let clLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(clLocation)
        let p = placemarks?.first
        return [p?.name, p?.locality].compactMap { $0 }.joined(separator: ", ")
    }
}
