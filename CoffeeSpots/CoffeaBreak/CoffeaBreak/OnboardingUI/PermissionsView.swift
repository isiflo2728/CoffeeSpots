//
//  PermissionsView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/4/26.
//

import SwiftUI
import CoreLocation
import AVFoundation

struct PermissionsView: View {
    @State private var locationManager = CLLocationManager()
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack {
            Color(red: 160/255, green: 115/255, blue: 70/255)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("Before We Begin")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("CoffeaBreak needs a couple of permissions to give you the best experience.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                VStack(spacing: 20) {
                    PermissionRow(
                        icon: "location.fill",
                        title: "Location",
                        description: "Find coffee spots near you on the map"
                    )
                    PermissionRow(
                        icon: "camera.fill",
                        title: "Camera",
                        description: "Take photos of your favorite coffee spots"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    locationManager.requestWhenInUseAuthorization()
                    AVCaptureDevice.requestAccess(for: .video) { _ in }
                    onContinue()
                } label: {
                    Text("Allow All")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .foregroundColor(.brown)
                        .clipShape(.capsule)
                }

                Button {
                    onContinue()
                } label: {
                    Text("Not Now")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    PermissionsView()
}
