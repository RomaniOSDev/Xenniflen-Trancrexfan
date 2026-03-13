//
//  GroundingStepsView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct GroundingStepsView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GroundingStepsViewModel
    @State private var showResult = false
    @State private var earnedStars = 0
    @State private var activityDuration: Double = 0
    @State private var newAchievement: Achievement?

    init(level: ActivityLevel) {
        _viewModel = StateObject(wrappedValue: GroundingStepsViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("Grounding Steps")
                        .font(.title2.bold())
                        .foregroundColor(.appTextPrimary)
                    Text("Move through each gentle step to connect with your senses and the present moment.")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                        GroundingStepCard(
                            step: step,
                            index: index,
                            isCurrent: index == viewModel.currentIndex,
                            isCompleted: index < viewModel.currentIndex || viewModel.completed
                        )
                    }

                    if !viewModel.completed {
                        Button(action: viewModel.advance) {
                            Text(viewModel.currentIndex == viewModel.steps.count - 1 ? "Finish step" : "Next step")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .primaryButtonBackground(cornerRadius: 14)
                        }
                        .padding(.top, 8)
                    } else {
                        Button(action: finishActivity) {
                            Text("Complete")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .primaryButtonBackground(cornerRadius: 14)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                activityTitle: ActivityKind.groundingSteps.title,
                level: viewModel.level,
                starsEarned: earnedStars,
                durationSeconds: activityDuration,
                activityId: ActivityKind.groundingSteps.rawValue,
                newAchievement: newAchievement,
                onNextLevel: { showResult = false; dismiss() },
                onRetry: { showResult = false },
                onBackToLevels: { showResult = false; dismiss() }
            )
            .environmentObject(appStorage)
        }
    }

    private func finishActivity() {
        activityDuration = viewModel.durationSeconds
        earnedStars = viewModel.starsEarned()
        let oldAchievementIds = Set(appStorage.achievements.map { $0.id })
        let prevStars = appStorage.stars(activity: ActivityKind.groundingSteps.rawValue, level: viewModel.level)
        if earnedStars > prevStars {
            appStorage.setStars(earnedStars, activity: ActivityKind.groundingSteps.rawValue, level: viewModel.level)
        }
        appStorage.addPlayTime(seconds: activityDuration)
        appStorage.incrementActivitiesPlayed()
        appStorage.recordActivityCompletion(starsEarned: earnedStars)
        appStorage.incrementProgramProgress(.grounding)
        newAchievement = appStorage.achievements.first { !oldAchievementIds.contains($0.id) }
        showResult = true
    }
}

struct GroundingStepCard: View {
    let step: GroundingStep
    let index: Int
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(index + 1)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : (isCurrent ? "circle.dotted" : "circle"))
                    .foregroundColor(isCompleted ? .appPrimary : .appTextSecondary)
            }
            Text(step.title)
                .font(.subheadline.bold())
                .foregroundColor(.appTextPrimary)
            Text(step.detail)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .padding(14)
        .subtleCard(cornerRadius: 14)
    }
}

#Preview {
    NavigationStack {
        GroundingStepsView(level: .easy)
            .environmentObject(AppStorage.shared)
    }
}
