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

    private let preset: NatureHarmonyPreset

    init(level: ActivityLevel) {
        let selectedPreset = NatureHarmonyView.defaultPresetForCurrentTime()
        self.preset = selectedPreset
        _viewModel = StateObject(wrappedValue: NatureHarmonyViewModel(level: level, preset: selectedPreset))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sessionTitle)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    Text(sessionDescription)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal, 16)

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

    private static func defaultPresetForCurrentTime() -> NatureHarmonyPreset {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return .relax
        case 12..<18: return .focus
        default: return .sleep
        }
    }

    private var sessionTitle: String {
        switch preset {
        case .relax: return "Create a calm garden"
        case .focus: return "Shape a focused grove"
        case .sleep: return "Build an evening sanctuary"
        }
    }

    private var sessionDescription: String {
        let base: String
        switch preset {
        case .relax:
            base = "Gently place each element where it feels balanced. Let the scene open up your breathing."
        case .focus:
            base = "Gather elements closer to the center to create a clear focal point for your attention."
        case .sleep:
            base = "Let elements drift lower in the scene, as if the garden is settling into night."
        }
        return base
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
