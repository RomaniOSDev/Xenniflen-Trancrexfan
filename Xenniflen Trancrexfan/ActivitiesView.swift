//
//  ActivitiesView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct ActivitySelection: Hashable {
    let activity: ActivityKind
    let level: ActivityLevel
}

struct ActivitiesView: View {
    @EnvironmentObject var appStorage: AppStorage
    @State private var selection: ActivitySelection?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        focusSection
                        ForEach(ActivityLevel.allCases) { level in
                            LevelSectionView(
                                level: level,
                                isUnlocked: appStorage.isLevelUnlocked(level: level),
                                totalStars: appStorage.totalStars,
                                activities: ActivityKind.allCases,
                                appStorage: appStorage,
                                onSelect: { activity in
                                    selection = ActivitySelection(activity: activity, level: level)
                                }
                            )
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selection) { s in
                activityDestination(activity: s.activity, level: s.level)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appStorageDidReset)) { _ in
            selection = nil
        }
    }

    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            NavigationLink(destination: FocusTimerView().environmentObject(appStorage)) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSurface, Color.appSurface.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.appPrimary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus Timer")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)
                        Text("5, 10 or 15 min of quiet focus")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appTextSecondary)
                }
                .padding(12)
                .subtleCard(cornerRadius: 12)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
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

struct LevelSectionView: View {
    let level: ActivityLevel
    let isUnlocked: Bool
    let totalStars: Int
    let activities: [ActivityKind]
    let appStorage: AppStorage
    let onSelect: (ActivityKind) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(level.displayName)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                if !isUnlocked {
                    Text("(\(starsNeededForLevel) stars to unlock)")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(activities) { activity in
                    ActivityCardView(
                        activity: activity,
                        level: level,
                        isUnlocked: isUnlocked,
                        stars: appStorage.stars(activity: activity.rawValue, level: level),
                        onTap: { if isUnlocked { onSelect(activity) } }
                    )
                }
            }
        }
    }

    private var starsNeededForLevel: Int {
        switch level {
        case .easy: return 0
        case .normal: return 3
        case .hard: return 9
        }
    }
}

struct ActivityCardView: View {
    let activity: ActivityKind
    let level: ActivityLevel
    let isUnlocked: Bool
    let stars: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface, Color.appSurface.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 8)
                    if isUnlocked {
                        ActivityIconView(activity: activity)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                Text(activity.title)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(i < stars ? Color.appPrimary : Color.appTextSecondary)
                    }
                }
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

struct ActivityIconView: View {
    let activity: ActivityKind

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 8, dy: 8)
            switch activity {
            case .natureHarmony:
                context.fill(Path(ellipseIn: rect), with: .color(Color.appPrimary))
                context.fill(Path(ellipseIn: rect.insetBy(dx: 12, dy: 12)), with: .color(Color.appAccent.opacity(0.8)))
            case .artisticExpression:
                context.stroke(Path(roundedRect: rect, cornerSize: CGSize(width: 8, height: 8)), with: .color(Color.appPrimary), lineWidth: 3)
                context.fill(Path(ellipseIn: CGRect(x: rect.midX - 8, y: rect.midY - 12, width: 16, height: 16)), with: .color(Color.appAccent))
            case .mindfulJourney:
                context.stroke(Path(ellipseIn: rect), with: .color(Color.appPrimary), lineWidth: 2)
                context.stroke(Path(ellipseIn: rect.insetBy(dx: 15, dy: 15)), with: .color(Color.appAccent), lineWidth: 2)
            case .gratitudeFlow:
                let heartRect = rect.insetBy(dx: 6, dy: 10)
                var p = Path()
                let topCenter = CGPoint(x: heartRect.midX, y: heartRect.minY + heartRect.height * 0.3)
                p.move(to: topCenter)
                p.addCurve(
                    to: CGPoint(x: heartRect.minX, y: heartRect.minY + heartRect.height * 0.35),
                    control1: CGPoint(x: heartRect.midX - heartRect.width * 0.25, y: heartRect.minY),
                    control2: CGPoint(x: heartRect.minX, y: heartRect.minY)
                )
                p.addCurve(
                    to: CGPoint(x: heartRect.midX, y: heartRect.maxY),
                    control1: CGPoint(x: heartRect.minX, y: heartRect.maxY * 0.9),
                    control2: CGPoint(x: heartRect.midX - 4, y: heartRect.maxY)
                )
                p.addCurve(
                    to: CGPoint(x: heartRect.maxX, y: heartRect.minY + heartRect.height * 0.35),
                    control1: CGPoint(x: heartRect.midX + 4, y: heartRect.maxY),
                    control2: CGPoint(x: heartRect.maxX, y: heartRect.maxY * 0.9)
                )
                p.addCurve(
                    to: topCenter,
                    control1: CGPoint(x: heartRect.maxX, y: heartRect.minY),
                    control2: CGPoint(x: heartRect.midX + heartRect.width * 0.25, y: heartRect.minY)
                )
                context.fill(p, with: .color(Color.appPrimary))
                context.stroke(p, with: .color(Color.appAccent), lineWidth: 2)
            case .groundingSteps:
                let outer = rect
                let inner = rect.insetBy(dx: 10, dy: 10)
                context.stroke(Path(roundedRect: outer, cornerSize: CGSize(width: 10, height: 10)), with: .color(Color.appPrimary), lineWidth: 2)
                context.stroke(Path(roundedRect: inner, cornerSize: CGSize(width: 8, height: 8)), with: .color(Color.appAccent), lineWidth: 2)
                let midLine = Path { p in
                    p.move(to: CGPoint(x: rect.midX, y: outer.minY + 6))
                    p.addLine(to: CGPoint(x: rect.midX, y: outer.maxY - 6))
                }
                context.stroke(midLine, with: .color(Color.appPrimary.opacity(0.6)), lineWidth: 2)
            }
        }
        .frame(width: 64, height: 64)
    }
}

#Preview {
    ActivitiesView()
        .environmentObject(AppStorage.shared)
}
