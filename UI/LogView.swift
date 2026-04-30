//
//  LogView.swift
//  CafeSpots
//
//  Created by Isidoro Flores on 4/7/26.
//

import SwiftUI
import PhotosUI
import UIKit
import MapKit

struct LogView: View {
    @State private var viewModel: LogViewModel

    // UI-only state
    @State private var showCamera = false
    @State private var showPhotoSource = false

    init(homeViewModel: HomeViewModel) {
        _viewModel = State(initialValue: LogViewModel(homeViewModel: homeViewModel))
    }

    var body: some View {
        NavigationStack {
            Form {
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
                            .onTapGesture { showPhotoSource = true }
                    } else {
                        Button {
                            showPhotoSource = true
                        } label: {
                            Label("Add Photo", systemImage: "camera")
                        }
                    }
                }

                Section("Cafe") {
                    TextField("Name", text: $viewModel.name)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rating")
                            Spacer()
                            Text(String(format: "%.1f", viewModel.rating))
                                .fontWeight(.semibold)
                        }
                        Slider(value: $viewModel.rating, in: 0...10, step: 0.5)
                            .tint(.brown)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Rating")
                }

                Section("Location") {
                    if let location = viewModel.location {
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
                    } else {
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
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Log a Spot")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .confirmationDialog("Add Photo", isPresented: $showPhotoSource) {
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    Text("Photo Library")
                }
                Button("Camera") { showCamera = true }
                if viewModel.imageData != nil {
                    Button("Remove Photo", role: .destructive) { viewModel.removePhoto() }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView(imageData: $viewModel.imageData)
                    .ignoresSafeArea()
            }
            .onChange(of: viewModel.selectedPhoto) { _, _ in
                Task { await viewModel.handlePhotoSelection() }
            }
            .alert("Spot Saved!", isPresented: $viewModel.showConfirmation) {
                Button("OK") { viewModel.resetForm() }
            } message: {
                Text("\(viewModel.savedSpotName) has been added to your feed.")
            }
        }
    }
}

// MARK: - Camera Picker

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        init(_ parent: CameraPickerView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    LogView(homeViewModel: HomeViewModel())
}
