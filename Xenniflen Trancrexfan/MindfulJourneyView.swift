//
//  MindfulJourneyView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct MindfulJourneyView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MindfulJourneyViewModel
    @State private var showResult = false
    @State private var earnedStars = 0
    @State private var activityDuration: Double = 0
    @State private var newAchievement: Achievement?

    init(level: ActivityLevel) {
        _viewModel = StateObject(wrappedValue: MindfulJourneyViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 32) {
                    if !viewModel.isRunning && !viewModel.isComplete {
                        Text("Mindful breathing")
                            .font(.title2.bold())
                            .foregroundColor(.appTextPrimary)
                        Text("Follow the circle and your breath. Complete \(viewModel.cyclesToComplete) cycles.")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button(action: { viewModel.start() }) {
                            Text("Start")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .primaryButtonBackground(cornerRadius: 12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    } else if viewModel.isRunning || viewModel.isComplete {
                        breathingVisual
                        Text(viewModel.phaseLabel)
                            .font(.title2.bold())
                            .foregroundColor(.appTextPrimary)
                        if viewModel.isComplete {
                            Text("Well done! You completed \(viewModel.completedCycles) cycles.")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
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
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
                    }
                }
                .padding(24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stop()
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                activityTitle: ActivityKind.mindfulJourney.title,
                level: viewModel.level,
                starsEarned: earnedStars,
                durationSeconds: activityDuration,
                activityId: 3,
                newAchievement: newAchievement,
                onNextLevel: { showResult = false; dismiss() },
                onRetry: { showResult = false; viewModel.reset(); viewModel.start() },
                onBackToLevels: { showResult = false; dismiss() }
            )
            .environmentObject(appStorage)
        }
    }

    private var breathingVisual: some View {
        ZStack {
            Circle()
                .stroke(Color.appTextSecondary.opacity(0.3), lineWidth: 4)
                .frame(width: 180, height: 180)
            Circle()
                .fill(Color.appAccent.opacity(0.4))
                .frame(width: 160 * viewModel.circleScale, height: 160 * viewModel.circleScale)
                .animation(.easeInOut(duration: 0.3), value: viewModel.circleScale)
            Circle()
                .stroke(Color.appPrimary, lineWidth: 3)
                .frame(width: 160 * viewModel.circleScale, height: 160 * viewModel.circleScale)
                .animation(.easeInOut(duration: 0.3), value: viewModel.circleScale)
        }
        .frame(height: 220)
    }

    private func finishActivity() {
        activityDuration = viewModel.durationSeconds
        earnedStars = viewModel.calculateStars()
        let oldAchievementIds = Set(appStorage.achievements.map { $0.id })
        let prevStars = appStorage.stars(activity: 3, level: viewModel.level)
        if earnedStars > prevStars {
            appStorage.setStars(earnedStars, activity: 3, level: viewModel.level)
        }
        appStorage.addPlayTime(seconds: activityDuration)
        appStorage.incrementActivitiesPlayed()
        appStorage.recordActivityCompletion(starsEarned: earnedStars)
        appStorage.incrementProgramProgress(.breathing)
        newAchievement = appStorage.achievements.first { !oldAchievementIds.contains($0.id) }
        showResult = true
    }
}

#Preview {
    NavigationStack {
        MindfulJourneyView(level: .easy)
            .environmentObject(AppStorage.shared)
    }
}
