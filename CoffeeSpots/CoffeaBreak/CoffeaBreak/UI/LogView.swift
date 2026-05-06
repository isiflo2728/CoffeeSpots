//
//  LogView.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import SwiftUI
import UIKit
import MapKit

struct LogView: View {
    @State private var viewModel: LogViewModel
    @Binding var isShowing: Bool
    @State private var showRanking = false

    init(viewModel: LogViewModel, isShowing: Binding<Bool>) {
        _viewModel = State(initialValue: viewModel)
        _isShowing = isShowing
    }

    var body: some View {
        Form {
            photoSection
            cafeSection
            locationSection
            notesSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Espresso yourself")
                    .italic()
                    .font(.headline)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    if viewModel.existingSpots.isEmpty {
                        Task {
                            viewModel.rating = 5.0
                            await viewModel.save()
                            isShowing = false
                        }
                    } else {
                        showRanking = true
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { isShowing = false }
            }
        }
        .overlay { savingOverlay }
        .sheet(isPresented: $showRanking) {
            RankingView(newSpotName: viewModel.name, spots: viewModel.existingSpots) { rating in
                viewModel.rating = rating
                Task {
                    await viewModel.save()
                    isShowing = false
                }
            }
        }
        .alert("Spot Saved!", isPresented: $viewModel.showConfirmation) {
            Button("OK") { viewModel.resetForm() }
        } message: {
            Text("\(viewModel.savedSpotName) has been added to your feed.")
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var photoSection: some View {
        Section("Photo") {
            if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
        }
    }

    private var cafeSection: some View {
        Section("Cafe") {
            TextField("Name", text: $viewModel.name)
        }
    }

    @ViewBuilder
    private var locationSection: some View {
        Section("Location") {
            if let location = viewModel.location {
                locationRow(location)
            } else {
                locationSearch
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
        }
    }

    // MARK: - Location Helpers

    private func locationRow(_ location: CafeSpot.CodableCoordinates) -> some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.locationName.isEmpty
                     ? String(format: "%.4f, %.4f", location.latitude, location.longitude)
                     : viewModel.locationName)
                    .font(.subheadline)
                if viewModel.locationFromPhoto {
                    Text("From photo metadata")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button("Remove") { viewModel.removeLocation() }
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var locationSearch: some View {
        TextField("Search for a location...", text: $viewModel.locationQuery)
            .onChange(of: viewModel.locationQuery) { _, _ in
                Task { await viewModel.searchLocations() }
            }
        ForEach(viewModel.searchResults, id: \.self) { item in
            Button {
                viewModel.selectLocation(item)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    if let title = item.placemark.title {
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var savingOverlay: some View {
        if viewModel.isSaving {
            ProgressView()
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    LogView(viewModel: LogViewModel(homeViewModel: HomeViewModel()), isShowing: .constant(true))
}
