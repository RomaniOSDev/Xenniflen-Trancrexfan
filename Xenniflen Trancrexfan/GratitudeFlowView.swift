//
//  GratitudeFlowView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct GratitudeFlowView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GratitudeFlowViewModel
    @State private var showResult = false
    @State private var earnedStars = 0
    @State private var activityDuration: Double = 0
    @State private var newAchievement: Achievement?

    init(level: ActivityLevel) {
        _viewModel = StateObject(wrappedValue: GratitudeFlowViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Gratitude Flow")
                        .font(.title2.bold())
                        .foregroundColor(.appTextPrimary)
                    Text("Gently choose a few things you feel grateful for right now. There is no wrong answer.")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.leading)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.prompts) { prompt in
                            GratitudePromptRow(
                                text: prompt.text,
                                isSelected: viewModel.selected.contains(prompt)
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    viewModel.toggle(prompt)
                                }
                            }
                        }
                    }

                    Button(action: finishActivity) {
                        Text("Finish")
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
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                activityTitle: ActivityKind.gratitudeFlow.title,
                level: viewModel.level,
                starsEarned: earnedStars,
                durationSeconds: activityDuration,
                activityId: ActivityKind.gratitudeFlow.rawValue,
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
        let prevStars = appStorage.stars(activity: ActivityKind.gratitudeFlow.rawValue, level: viewModel.level)
        if earnedStars > prevStars {
            appStorage.setStars(earnedStars, activity: ActivityKind.gratitudeFlow.rawValue, level: viewModel.level)
        }
        appStorage.addPlayTime(seconds: activityDuration)
        appStorage.incrementActivitiesPlayed()
        appStorage.recordActivityCompletion(starsEarned: earnedStars)
        appStorage.incrementProgramProgress(.gratitude)
        newAchievement = appStorage.achievements.first { !oldAchievementIds.contains($0.id) }
        showResult = true
    }
}

struct GratitudePromptRow: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                    .font(.title3)
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(12)
            .subtleCard(cornerRadius: 12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

#Preview {
    NavigationStack {
        GratitudeFlowView(level: .easy)
            .environmentObject(AppStorage.shared)
    }
}

