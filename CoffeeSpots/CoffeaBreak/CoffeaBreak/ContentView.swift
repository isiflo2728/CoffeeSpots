//
//  ContentView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 4/30/26.
//

import SwiftUI


struct ContentView: View {
    @State private var viewModel = HomeViewModel()
   
    @State private var authModel = AuthViewModel()
    

    var body: some View {
        
        Group {
            if authModel.isLoading {
                VStack{
                    ProgressView(){
                    }
                }
            } else if authModel.isAuthenticated {
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
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                }
            } else {
                OnboardingView()
            }
        }
        .environment(authModel)
        .task {
            await authModel.checkingUser()
        }
    
    }
}

#Preview {
    ContentView()
}
