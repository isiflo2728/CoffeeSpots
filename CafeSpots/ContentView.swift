//
//  ContentView.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            LogView(homeViewModel: viewModel)
                .tabItem {
                    Label("Log", systemImage: "note.text.badge.plus")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    ContentView()
}
