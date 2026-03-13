//
//  DrawingGalleryView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import UIKit

struct DrawingGalleryView: View {
    @EnvironmentObject var appStorage: AppStorage

    private var images: [UIImage] {
        appStorage.savedDrawings.compactMap { UIImage(data: $0) }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if images.isEmpty {
                Text("No saved creations yet.\nSave a drawing from Artistic Expression to see it here.")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .subtleCard(cornerRadius: 14)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Creations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DrawingGalleryView()
            .environmentObject(AppStorage.shared)
    }
}

