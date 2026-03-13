//
//  ArtisticExpressionView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import UIKit

struct ArtisticExpressionView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ArtisticExpressionViewModel
    @State private var showResult = false
    @State private var earnedStars = 0
    @State private var activityDuration: Double = 0
    @State private var newAchievement: Achievement?
    @State private var showShareSheet = false
    @State private var canvasImage: UIImage?
    @State private var currentGuide: String = ""

    init(level: ActivityLevel) {
        _viewModel = StateObject(wrappedValue: ArtisticExpressionViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(spacing: 16) {
                        if !currentGuide.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today's prompt")
                                    .font(.footnote.uppercaseSmallCaps())
                                    .foregroundColor(.appAccent)
                                Text(currentGuide)
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                        }
                        canvasView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 12) {
                    if viewModel.level != .easy {
                        Picker("Texture", selection: $viewModel.textureMode) {
                            Text("Smooth").tag(0)
                            Text("Rough").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                    }

                    HStack(spacing: 16) {
                        ForEach(Array(viewModel.colors.enumerated()), id: \.offset) { _, c in
                            Circle()
                                .fill(c)
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.white, lineWidth: viewModel.currentColor == c ? 3 : 0))
                                .onTapGesture {
                                    viewModel.currentColor = c
                                    viewModel.isErase = false
                                }
                        }
                        if viewModel.level != .easy {
                            Image(systemName: "eraser.fill")
                                .font(.title2)
                                .foregroundColor(.appTextSecondary)
                                .frame(width: 44, height: 44)
                                .onTapGesture { viewModel.isErase = true }
                        }
                    }
                    .padding(.vertical, 8)

                    HStack(spacing: 12) {
                        ForEach(viewModel.brushSizes, id: \.self) { size in
                            Button(action: { viewModel.brushSize = size }) {
                                Circle()
                                    .fill(Color.appTextPrimary)
                                    .frame(width: size * 2, height: size * 2)
                            }
                            .frame(minWidth: 44, minHeight: 44)
                        }
                    }

                    HStack(spacing: 12) {
                        Button(action: { viewModel.clear() }) {
                            Text("Clear")
                                .font(.subheadline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.appTextPrimary)
                                .frame(minHeight: 44)
                                .padding(.horizontal, 16)
                        }
                        Button(action: finishActivity) {
                            Text("Finish")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(minHeight: 44)
                                .padding(.horizontal, 24)
                                .primaryButtonBackground(cornerRadius: 12)
                        }
                        if viewModel.level != .easy {
                            Button(action: captureAndShare) {
                                Text("Share")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.appAccent)
                                    .frame(minHeight: 44)
                                    .padding(.horizontal, 16)
                            }
                            Button(action: saveToGallery) {
                                Text("Save")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.appAccent)
                                    .frame(minHeight: 44)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(16)
                }
                .background(Color.appSurface)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if currentGuide.isEmpty {
                currentGuide = Self.randomGuide(for: viewModel.level)
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                activityTitle: ActivityKind.artisticExpression.title,
                level: viewModel.level,
                starsEarned: earnedStars,
                durationSeconds: activityDuration,
                activityId: 2,
                newAchievement: newAchievement,
                onNextLevel: { showResult = false; dismiss() },
                onRetry: { showResult = false; viewModel.reset() },
                onBackToLevels: { showResult = false; dismiss() }
            )
            .environmentObject(appStorage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = canvasImage {
                ShareSheet(items: [img])
            }
        }
    }

    private var canvasView: some View {
        Canvas { context, size in
            for stroke in viewModel.strokes {
                guard stroke.points.count >= 2 else { continue }
                var path = Path()
                path.move(to: stroke.points[0])
                for p in stroke.points.dropFirst() {
                    path.addLine(to: p)
                }
                if stroke.isErase {
                    context.blendMode = .clear
                    context.stroke(path, with: .color(.clear), lineWidth: stroke.lineWidth * 2)
                } else {
                    context.blendMode = .normal
                    context.stroke(path, with: .color(stroke.color), lineWidth: stroke.lineWidth)
                }
            }
            if !viewModel.currentStroke.isEmpty && viewModel.currentStroke.count >= 2 {
                var path = Path()
                path.move(to: viewModel.currentStroke[0])
                for p in viewModel.currentStroke.dropFirst() {
                    path.addLine(to: p)
                }
                if viewModel.isErase {
                    context.blendMode = .clear
                    context.stroke(path, with: .color(.clear), lineWidth: viewModel.brushSize * 2)
                } else {
                    context.stroke(path, with: .color(viewModel.currentColor), lineWidth: viewModel.brushSize)
                }
            }
        }
        .frame(minWidth: 350, minHeight: 400)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(16)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    viewModel.addPoint(value.location)
                }
                .onEnded { _ in
                    viewModel.endStroke()
                }
        )
    }

    private func finishActivity() {
        activityDuration = viewModel.durationSeconds
        earnedStars = viewModel.calculateStars()
        if earnedStars == 0 { earnedStars = 1 }
        let oldAchievementIds = Set(appStorage.achievements.map { $0.id })
        let prevStars = appStorage.stars(activity: 2, level: viewModel.level)
        if earnedStars > prevStars {
            appStorage.setStars(earnedStars, activity: 2, level: viewModel.level)
        }
        appStorage.addPlayTime(seconds: activityDuration)
        appStorage.incrementActivitiesPlayed()
        appStorage.recordActivityCompletion(starsEarned: earnedStars)
        appStorage.guidedDrawingsCompleted += 1
        newAchievement = appStorage.achievements.first { !oldAchievementIds.contains($0.id) }
        showResult = true
    }

    private func captureAndShare() {
        let content = canvasView.frame(width: 350, height: 400)
        let renderer = ImageRenderer(content: content)
        canvasImage = renderer.uiImage
        showShareSheet = true
    }

    private func saveToGallery() {
        let content = canvasView.frame(width: 350, height: 400)
        let renderer = ImageRenderer(content: content)
        if let image = renderer.uiImage, let data = image.jpegData(compressionQuality: 0.8) {
            appStorage.addDrawing(data)
        }
    }

    private static func randomGuide(for level: ActivityLevel) -> String {
        let easyGuides = [
            "Paint with only warm colors and see how it feels.",
            "Draw a simple shape that matches your breathing rhythm."
        ]
        let normalGuides = [
            "Create three circles that grow and fade like your breath.",
            "Use only two colors to describe how your day feels."
        ]
        let hardGuides = [
            "Blend light and dark tones to capture a calm moment.",
            "Fill the space with repeating shapes that feel soothing to you."
        ]
        switch level {
        case .easy:
            return easyGuides.randomElement() ?? easyGuides[0]
        case .normal:
            return normalGuides.randomElement() ?? normalGuides[0]
        case .hard:
            return hardGuides.randomElement() ?? hardGuides[0]
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ArtisticExpressionView(level: .easy)
            .environmentObject(AppStorage.shared)
    }
}
