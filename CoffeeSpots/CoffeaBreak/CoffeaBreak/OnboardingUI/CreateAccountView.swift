//
//  CreateAccountView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/4/26.
//

import SwiftUI
import PhotosUI

struct CreateAccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var userName = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var profileImageData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let service = UserService()

    var body: some View {
        ZStack {
            Color(red: 160/255, green: 115/255, blue: 70/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Your Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // Profile photo picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 36))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                profileImageData = data
                                if let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }

                    VStack(spacing: 16) {
                        AccountField(placeholder: "Username", text: $userName)
                        AccountField(placeholder: "Display Name", text: $displayName)
                        AccountField(placeholder: "Bio (optional)", text: $bio)
                    }
                    .padding(.horizontal, 32)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Button {
                        Task { await createAccount() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.brown)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(.capsule)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .foregroundColor(.brown)
                                .clipShape(.capsule)
                        }
                    }
                    .disabled(userName.isEmpty || displayName.isEmpty || isLoading)
                    .opacity(userName.isEmpty || displayName.isEmpty ? 0.6 : 1)

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private func createAccount() async {
        isLoading = true
        errorMessage = nil
        let user = UserModel(
            id: UUID(),
            userName: userName,
            displayName: displayName,
            bio: bio.isEmpty ? nil : bio,
            imageData: profileImageData,
            cloudKitRecordID: nil
        )
        do {
            try await service.save(user)
            authViewModel.isAuthenticated = true
        } catch {
            errorMessage = "Failed to create account. Please try again."
        }
        isLoading = false
    }
}

struct AccountField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundColor(.white)
            .tint(.white)
    }
}

#Preview {
    CreateAccountView()
        .environment(AuthViewModel())
}
