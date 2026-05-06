//
//  RankingView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/6/26.
//

import SwiftUI
import UIKit

struct RankingView: View {
    let newSpotName: String
    private let sortedSpots: [CafeSpot]
    let onFinished: (Double) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var lo: Int
    @State private var hi: Int
    @State private var dragOffset: CGFloat = 0

    private let swipeThreshold: CGFloat = 90

    init(newSpotName: String, spots: [CafeSpot], onFinished: @escaping (Double) -> Void) {
        self.newSpotName = newSpotName
        self.sortedSpots = spots.sorted { $0.rating < $1.rating }
        self.onFinished = onFinished
        _lo = State(initialValue: 0)
        _hi = State(initialValue: max(0, spots.count - 1))
    }

    private var mid: Int { (lo + hi) / 2 }
    private var spot: CafeSpot { sortedSpots[mid] }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            (Text("Is ") + Text(newSpotName).bold() + Text(" better or worse than..."))
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            comparisonCard
                .gesture(dragGesture)

            HStack {
                Label("Worse", systemImage: "arrow.left")
                    .foregroundStyle(.red)
                Spacer()
                Label("Better", systemImage: "arrow.right")
                    .foregroundStyle(.green)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 32)

            Spacer()
        }
        .presentationDetents([.large])
    }

    private var comparisonCard: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let data = spot.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 420)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(String(format: "%.1f / 10", spot.rating))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(20)

            HStack {
                Text("WORSE")
                    .font(.title.bold())
                    .foregroundStyle(.red)
                    .opacity(dragOffset < -20 ? Double(min(abs(dragOffset) / swipeThreshold, 1.0)) : 0)
                    .padding(16)
                Spacer()
                Text("BETTER")
                    .font(.title.bold())
                    .foregroundStyle(.green)
                    .opacity(dragOffset > 20 ? Double(min(dragOffset / swipeThreshold, 1.0)) : 0)
                    .padding(16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 24)
        .offset(x: dragOffset)
        .rotationEffect(.degrees(Double(dragOffset) / 25), anchor: .bottom)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in dragOffset = value.translation.width }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    commit(better: true)
                } else if value.translation.width < -swipeThreshold {
                    commit(better: false)
                } else {
                    withAnimation(.spring(response: 0.4)) { dragOffset = 0 }
                }
            }
    }

    private func commit(better: Bool) {
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = better ? 600 : -600
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.25))
            dragOffset = 0
            if better { lo = mid + 1 } else { hi = mid - 1 }
            if lo > hi {
                onFinished(deriveRating())
                dismiss()
            }
        }
    }

    private func deriveRating() -> Double {
        if lo == 0 {
            return max(0, sortedSpots[0].rating - 1.5)
        } else if lo >= sortedSpots.count {
            return min(10, sortedSpots.last!.rating + 1.5)
        } else {
            return (sortedSpots[lo - 1].rating + sortedSpots[lo].rating) / 2.0
        }
    }
}
