//
//  ContentView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 4/30/26.
//

import SwiftUI


struct ContentView: View {
    @State private var viewModel = HomeViewModel()
    @State private var path = [Int]()
    

    var body: some View {
        
        NavigationStack {
            TabView {
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profilem", systemImage: "person.crop.circle")
                    }
            }
            
        }
    
    }
}

#Preview {
    ContentView()
}
