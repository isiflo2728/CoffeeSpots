//
//  AuthViewModel.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/1/26.
//

import Foundation


@Observable
class AuthViewModel {
    var isAuthenticated = false
    var isLoading: Bool = false
    
    
    private let service = UserService()
    var errorMessage: String?
    
    func checkingUser() async {
        isLoading = true
        do {
            let _ = try await service.fetchCurrentUser()
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
            print("Fetch failed with: \(error)")
        }
        
        isLoading = false
        
    }
}
