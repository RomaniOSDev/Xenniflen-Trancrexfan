//
//  ProfileView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appStorage: AppStorage
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        weeklyProgressSection
                        programsSection
                        statsSection
                        moodDiarySection
                        creationsSection
                        settingsSection
                        achievementsSection
                        resetSection
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Reset All Progress", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    appStorage.resetAll()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will clear all stars, progress, and statistics. This cannot be undone.")
            }
        }
    }

    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            VStack(spacing: 0) {
                StatRow(label: "This week", value: "\(appStorage.thisWeekSummary.stars) stars, \(appStorage.thisWeekSummary.activities) activities")
                Divider().background(Color.appTextSecondary.opacity(0.3))
                StatRow(label: "Last week", value: "\(appStorage.lastWeekSummary.stars) stars, \(appStorage.lastWeekSummary.activities) activities")
                if appStorage.thisWeekSummary.focusMinutes > 0 || appStorage.lastWeekSummary.focusMinutes > 0 {
                    Divider().background(Color.appTextSecondary.opacity(0.3))
                    StatRow(label: "Focus this week", value: "\(appStorage.thisWeekSummary.focusMinutes) min")
                }
            }
            .subtleCard(cornerRadius: 12)
        }
    }

    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Programs")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            VStack(spacing: 12) {
                ForEach(AppStorage.WellnessProgram.allCases, id: \.self) { program in
                    let progress = appStorage.programProgress(program)
                    let total = program.targetSessions
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: programIcon(program))
                                    .foregroundColor(.appAccent)
                                Text(programTitle(program))
                                    .font(.subheadline.bold())
                                    .foregroundColor(.appTextPrimary)
                            }
                            ProgressView(value: Double(progress), total: Double(total))
                                .tint(.appAccent)
                            Text("\(progress)/\(total) sessions")
                                .font(.caption2)
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .subtleCard(cornerRadius: 12)
                }
            }
        }
    }

    private var moodDiarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Diary")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            NavigationLink(destination: MoodDiaryView().environmentObject(appStorage)) {
                HStack {
                    Text("Log your mood and view recent entries")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appTextSecondary)
                }
                .padding(12)
                .subtleCard(cornerRadius: 12)
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            NavigationLink(destination: SettingsView().environmentObject(appStorage)) {
                HStack {
                    Text("Rate us, Privacy, Terms, Onboarding")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appTextSecondary)
                }
                .padding(12)
                .subtleCard(cornerRadius: 12)
            }
            .buttonStyle(.plain)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            VStack(spacing: 0) {
                StatRow(label: "Total stars", value: "\(appStorage.totalStars)")
                Divider().background(Color.appTextSecondary.opacity(0.3))
                StatRow(label: "Activities completed", value: "\(appStorage.totalActivitiesPlayed)")
                Divider().background(Color.appTextSecondary.opacity(0.3))
                StatRow(label: "Total play time", value: appStorage.totalPlayTimeFormatted)
                Divider().background(Color.appTextSecondary.opacity(0.3))
                StatRow(label: "Focus sessions", value: "\(appStorage.focusTimerCompletions)")
            }
            .subtleCard(cornerRadius: 12)
        }
    }

    private var creationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Creations")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            if appStorage.savedDrawings.isEmpty {
                Text("Save drawings in Artistic Expression to see them here.")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .subtleCard(cornerRadius: 12)
            } else {
                NavigationLink(destination: DrawingGalleryView().environmentObject(appStorage)) {
                    HStack {
                        Text("View saved drawings (\(appStorage.savedDrawings.count))")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(12)
                    .subtleCard(cornerRadius: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            if appStorage.achievements.isEmpty {
                Text("Complete activities to unlock achievements.")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .subtleCard(cornerRadius: 12)
            } else {
                ForEach(appStorage.achievements) { a in
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.appPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.appTextPrimary)
                            Text(a.description)
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .subtleCard(cornerRadius: 12)
                }
            }
        }
    }

    private var resetSection: some View {
        Button(action: { showResetConfirmation = true }) {
            Text("Reset All Progress")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .padding(.top, 8)
    }
}

private func programTitle(_ program: AppStorage.WellnessProgram) -> String {
    switch program {
    case .breathing: return "Breathing"
    case .focus: return "Focus"
    case .grounding: return "Grounding"
    case .gratitude: return "Gratitude"
    }
}

private func programIcon(_ program: AppStorage.WellnessProgram) -> String {
    switch program {
    case .breathing: return "wind"
    case .focus: return "timer"
    case .grounding: return "leaf"
    case .gratitude: return "heart"
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundColor(.appTextPrimary)
        }
        .padding(12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppStorage.shared)
}
