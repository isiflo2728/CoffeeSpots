//
//  CameraView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/6/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct CameraView: View {
    @State private var viewModel: LogViewModel
    @State private var navigateToLog = false
    @Environment(\.dismiss) var dismiss
    @Binding var isShowing: Bool

    init(homeViewModel: HomeViewModel, isShowing: Binding<Bool>) {
        _viewModel = State(initialValue: LogViewModel(homeViewModel: homeViewModel))
        _isShowing = isShowing
    }

    var body: some View {
        ZStack {
            if navigateToLog {
                NavigationStack {
                    LogView(viewModel: viewModel, isShowing: $isShowing)
                }
                .transition(.move(edge: .trailing))
            } else {
                ZStack(alignment: .bottom) {
                    CameraPickerView(imageData: $viewModel.imageData, onComplete: {
                        if viewModel.imageData != nil {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                navigateToLog = true
                            }
                        } else {
                            dismiss()
                        }
                    })
                    .ignoresSafeArea()

                    HStack {
                        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(14)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 110)
                }
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
                .onChange(of: viewModel.selectedPhoto) { _, _ in
                    Task {
                        await viewModel.handlePhotoSelection()
                        if viewModel.imageData != nil {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                navigateToLog = true
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CameraView(homeViewModel: HomeViewModel(), isShowing: .constant(true))
}

// MARK: - Camera Picker

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    var onComplete: () -> Void

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
            parent.onComplete()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onComplete()
        }
    }
}
