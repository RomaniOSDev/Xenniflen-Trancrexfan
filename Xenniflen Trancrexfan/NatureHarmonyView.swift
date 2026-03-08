//
//  NatureHarmonyView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct NatureHarmonyView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NatureHarmonyViewModel
    @State private var canvasSize: CGSize = .zero
    @State private var showResult = false
    @State private var earnedStars = 0
    @State private var activityDuration: Double = 0
    @State private var newAchievement: Achievement?

    init(level: ActivityLevel) {
        _viewModel = StateObject(wrappedValue: NatureHarmonyViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSurface)
                            .frame(width: max(geo.size.width, 350), height: max(geo.size.height, 500))
                            .onAppear { canvasSize = CGSize(width: max(geo.size.width, 350), height: max(geo.size.height, 500)) }

                        ForEach(viewModel.elements) { el in
                            PlantElementView(element: el)
                                .position(el.position)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if !viewModel.hasDragStart(for: el.id) {
                                                viewModel.beginDrag(id: el.id)
                                            }
                                            viewModel.updateDrag(id: el.id, translation: value.translation)
                                        }
                                        .onEnded { value in
                                            viewModel.endDrag(id: el.id, translation: value.translation)
                                        }
                                )
                        }
                    }
                    .frame(width: max(geo.size.width, 350), height: max(geo.size.height, 500))
                }
                .frame(minWidth: 350, minHeight: 500)
                .padding(16)
            }
            .overlay(alignment: .bottom) {
                if viewModel.isComplete {
                    Button(action: finishActivity) {
                        Text("Finish")
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .primaryButtonBackground(cornerRadius: 12)
                    }
                    .padding(16)
                    .padding(.bottom, 8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                activityTitle: ActivityKind.natureHarmony.title,
                level: viewModel.level,
                starsEarned: earnedStars,
                durationSeconds: activityDuration,
                activityId: 1,
                newAchievement: newAchievement,
                onNextLevel: { showResult = false; dismiss() },
                onRetry: { showResult = false; viewModel.reset() },
                onBackToLevels: { showResult = false; dismiss() }
            )
            .environmentObject(appStorage)
        }
    }

    private func finishActivity() {
        activityDuration = viewModel.durationSeconds
        earnedStars = viewModel.calculateStars(canvasSize: canvasSize)
        let oldAchievementIds = Set(appStorage.achievements.map { $0.id })
        let prevStars = appStorage.stars(activity: 1, level: viewModel.level)
        if earnedStars > prevStars {
            appStorage.setStars(earnedStars, activity: 1, level: viewModel.level)
        }
        appStorage.addPlayTime(seconds: activityDuration)
        appStorage.incrementActivitiesPlayed()
        appStorage.recordActivityCompletion(starsEarned: earnedStars)
        newAchievement = appStorage.achievements.first { !oldAchievementIds.contains($0.id) }
        showResult = true
    }
}

struct PlantElementView: View {
    let element: PlantElement

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height).insetBy(dx: 4, dy: 4)
            context.fill(Path(ellipseIn: rect), with: .color(Color.appPrimary))
            context.fill(Path(ellipseIn: rect.insetBy(dx: 6, dy: 6)), with: .color(Color.appAccent.opacity(0.8)))
        }
        .frame(width: 44, height: 44)
    }
}

#Preview {
    NavigationStack {
        NatureHarmonyView(level: .easy)
            .environmentObject(AppStorage.shared)
    }
}
