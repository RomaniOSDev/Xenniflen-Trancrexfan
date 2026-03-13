//
//  HomeView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

enum DiscoverLink: Hashable {
    case activity(ActivitySelection)
    case focusTimer
}

struct HomeView: View {
    @EnvironmentObject var appStorage: AppStorage
    @State private var discoverLink: DiscoverLink?

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private var todayMood: MoodType? {
        appStorage.moodForDate(todayDateString)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        quickActionsSection
                        programsSection
                        collectionsSection
                        insightsSection
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $discoverLink) { link in
                switch link {
                case .activity(let selection):
                    activityDestination(activity: selection.activity, level: selection.level)
                case .focusTimer:
                    FocusTimerView()
                }
            }
        }
    }

    private var headerSection: some View {
        let thisWeek = appStorage.thisWeekSummary
        return VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your journey")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    Text("\(appStorage.totalStars) stars • \(appStorage.totalActivitiesPlayed) activities")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    Text("This week: \(thisWeek.stars) stars, \(thisWeek.activities) activities")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    if let mood = todayMood {
                        Text("Mood")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text(mood.label)
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)
                    }
                    if appStorage.thisWeekSummary.focusMinutes > 0 {
                        Text("\(appStorage.thisWeekSummary.focusMinutes) min focus")
                            .font(.caption2)
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.appSurface, Color.appPrimary.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.4), radius: 22, x: 0, y: 14)
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NavigationLink(destination: MoodDiaryView().environmentObject(appStorage)) {
                        QuickActionCard(icon: "face.smiling", title: "Log mood", subtitle: "Capture how you feel")
                    }
                    NavigationLink(destination: FocusTimerView().environmentObject(appStorage)) {
                        QuickActionCard(icon: "timer", title: "Focus timer", subtitle: "5–15 minutes of stillness")
                    }
                    Button(action: {
                        discoverLink = .activity(ActivitySelection(activity: .mindfulJourney, level: .easy))
                    }) {
                        QuickActionCard(icon: "circle.dashed.inset.filled", title: "Breathing", subtitle: "Guided mindful journey")
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Programs")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            HStack(spacing: 12) {
                ForEach(AppStorage.WellnessProgram.allCases, id: \.self) { program in
                    let progress = appStorage.programProgress(program)
                    let total = program.targetSessions
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: programIcon(program))
                                .font(.caption)
                                .foregroundColor(.appAccent)
                            Text(programTitle(program))
                                .font(.caption.bold())
                                .foregroundColor(.appTextPrimary)
                        }
                        ProgressView(value: Double(progress), total: Double(total))
                            .tint(.appAccent)
                        Text("\(progress)/\(total) sessions")
                            .font(.caption2)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(12)
                    .subtleCard(cornerRadius: 12)
                }
            }
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

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collections")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            ThemedCollectionView(
                title: "Morning",
                subtitle: "Start your day with a short breathing exercise to set a calm intention.",
                buttonTitle: "Start",
                destination: .activity(ActivitySelection(activity: .mindfulJourney, level: .easy)),
                link: $discoverLink
            )
            ThemedCollectionView(
                title: "Before Sleep",
                subtitle: "Wind down with nature sounds. Arrange elements and create a peaceful soundscape.",
                buttonTitle: "Start",
                destination: .activity(ActivitySelection(activity: .natureHarmony, level: .easy)),
                link: $discoverLink
            )
            ThemedCollectionView(
                title: "Quick Break",
                subtitle: "Take 5 minutes of focus. No tasks, no distractions—just stillness.",
                buttonTitle: "Start",
                destination: .focusTimer,
                link: $discoverLink
            )
            ThemedCollectionView(
                title: "Creative Pause",
                subtitle: "Express yourself with colors. A short painting session can refresh your mind.",
                buttonTitle: "Start",
                destination: .activity(ActivitySelection(activity: .artisticExpression, level: .easy)),
                link: $discoverLink
            )
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifestyle insights")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            if let recommendation = appStorage.recommendationText {
                DiscoverCard(
                    title: "Today's suggestion",
                    text: recommendation
                )
            }
            DiscoverCard(
                title: "Daily Calm",
                text: "A few minutes of mindful breathing or gentle soundscapes help reset your focus and soften tension."
            )
            DiscoverCard(
                title: "Creative Flow",
                text: "Treat each drawing as a moment, not a masterpiece. Let colors and shapes simply reflect how you feel."
            )
            DiscoverCard(
                title: "Progress at Your Pace",
                text: "Stars track your journey, not your worth. Move between levels whenever it feels right for you."
            )
        }
    }

    @ViewBuilder
    private func activityDestination(activity: ActivityKind, level: ActivityLevel) -> some View {
        switch activity {
        case .natureHarmony:
            NatureHarmonyView(level: level)
        case .artisticExpression:
            ArtisticExpressionView(level: level)
        case .mindfulJourney:
            MindfulJourneyView(level: level)
        case .gratitudeFlow:
            GratitudeFlowView(level: level)
        case .groundingSteps:
            GroundingStepsView(level: level)
        }
    }
}

struct ThemedCollectionView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let destination: DiscoverLink
    @Binding var link: DiscoverLink?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Button(action: { link = destination }) {
                Text(buttonTitle)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 44)
                    .primaryButtonBackground(cornerRadius: 10)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .elevatedCard(cornerRadius: 12)
    }
}

struct DiscoverCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .subtleCard(cornerRadius: 12)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.appTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
        }
        .padding(14)
        .frame(width: 200, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 14, x: 0, y: 10)
    }
}

#warning("Rename file to HomeView.swift in Xcode if needed.")

#Preview {
    HomeView()
        .environmentObject(AppStorage.shared)
}
