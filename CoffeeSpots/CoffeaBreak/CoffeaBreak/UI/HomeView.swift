//
//  HomeView.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import SwiftUI
import UIKit

struct HomeView: View {
    var viewModel: HomeViewModel
@State private var isShowing = false
    @State private var isProfile = false
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.spots) { spot in
                        CafeCard(spot: spot)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("CafeSpots")
            .task {
                await viewModel.fetchSpots()
            }
            .overlay {
                if viewModel.spots.isEmpty {
                    ContentUnavailableView(
                        "No Spots Yet",
                        systemImage: "cup.and.saucer",
                        description: Text("Log your first cafe to get started.")
                    )
                }
            }
            .toolbar{
                ToolbarItem{
                    Button{
                       isShowing.toggle()
                    } label : {
                        Label("Add", systemImage: "plus")
                    }
                }
            }.sheet(isPresented: $isShowing){
                LogView(homeViewModel: viewModel)
            }
        }
        
    }
}

struct CafeCard: View {
    let spot: CafeSpot

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            ZStack(alignment: .bottomLeading) {
                if let data = spot.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                         .resizable()
                         .scaledToFill()
                         .frame(maxWidth: .infinity)
                         .frame(height: 180)
                         .clipped()
                         .allowsHitTesting(false)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 180)
                        .overlay {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                        }
                }

                // Rating badge
                Text(String(format: "%.1f", spot.rating))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.6), in: Capsule())
                    .padding(12)
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(spot.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                if let locationName = spot.locationName {
                    Label(locationName, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !spot.notes.isEmpty {
                    Text(spot.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
