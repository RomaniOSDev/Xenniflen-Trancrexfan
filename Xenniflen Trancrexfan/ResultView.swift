//
//  ResultView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var appStorage: AppStorage
    let activityTitle: String
    let level: ActivityLevel
    let starsEarned: Int
    let durationSeconds: Double
    let activityId: Int
    let newAchievement: Achievement?
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var displayedStarCount = 0
    @State private var showAchievementBanner = false

    private var durationFormatted: String {
        let t = Int(durationSeconds)
        let min = t / 60
        let sec = t % 60
        if min > 0 { return "\(min) min \(sec) sec" }
        return "\(sec) sec"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 32) {
                    Text("Complete")
                        .font(.title.bold())
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, 40)

                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { i in
                            StarView(filled: i < displayedStarCount)
                                .scaleEffect(i < displayedStarCount ? 1.2 : 0.8)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(i) * 0.15),
                                    value: displayedStarCount
                                )
                        }
                    }
                    .padding(.vertical, 16)

                    VStack(spacing: 12) {
                        statRow(label: "Activity", value: activityTitle)
                        statRow(label: "Level", value: level.displayName)
                        statRow(label: "Duration", value: durationFormatted)
                        statRow(label: "Stars earned", value: "\(starsEarned)")
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .elevatedCard(cornerRadius: 16)
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        Button(action: onNextLevel) {
                            Text("Next Level")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .primaryButtonBackground(cornerRadius: 12)
                        }
                        .padding(.horizontal, 16)

                        Button(action: onRetry) {
                            Text("Retry")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.appTextPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .padding(.horizontal, 16)

                        Button(action: onBackToLevels) {
                            Text("Back to Levels")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.appAccent)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .overlay(alignment: .top) {
                if showAchievementBanner, let a = newAchievement {
                    AchievementBanner(achievement: a)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                        .zIndex(1)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                displayedStarCount = starsEarned
            }
            checkNewAchievement()
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundColor(.appTextPrimary)
        }
    }

    private func checkNewAchievement() {
        if newAchievement != nil {
            withAnimation(.easeInOut(duration: 0.4)) {
                showAchievementBanner = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAchievementBanner = false
                }
            }
        }
    }
}

struct StarView: View {
    let filled: Bool

    var body: some View {
        ZStack {
            if filled {
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.appPrimary)
                    .shadow(color: Color.appPrimary.opacity(0.8), radius: 8)
            } else {
                Image(systemName: "star")
                    .font(.system(size: 44))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(width: 44, height: 44)
    }
}

struct AchievementBanner: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundColor(.appPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.appTextPrimary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

#Preview {
    ResultView(
        activityTitle: "Nature's Harmony",
        level: .easy,
        starsEarned: 2,
        durationSeconds: 65,
        activityId: 1,
        newAchievement: nil,
        onNextLevel: {},
        onRetry: {},
        onBackToLevels: {}
    )
    .environmentObject(AppStorage.shared)
}
