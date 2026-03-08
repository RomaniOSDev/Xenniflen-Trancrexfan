//
//  MoodDiaryView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct MoodDiaryView: View {
    @EnvironmentObject var appStorage: AppStorage
    @State private var selectedMood: MoodType?
    @State private var showingDate = Date()

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: showingDate)
    }

    private var todayMood: MoodType? {
        appStorage.moodForDate(dateString)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("How do you feel?")
                        .font(.title2.bold())
                        .foregroundColor(.appTextPrimary)

                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    HStack(spacing: 12) {
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: (selectedMood ?? todayMood) == mood
                            ) {
                                selectedMood = mood
                                appStorage.addMoodEntry(MoodEntry(dateString: dateString, mood: mood))
                            }
                            .frame(minWidth: 44, minHeight: 44)
                        }
                    }
                    .padding(.vertical, 8)

                    if todayMood != nil {
                        Text("Saved as \(todayMood!.label)")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }

                    Divider().background(Color.appTextSecondary.opacity(0.3))

                    Text("Recent entries")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)

                    if appStorage.moodEntries.isEmpty {
                        Text("No entries yet. Tap a mood above to add one.")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        .subtleCard(cornerRadius: 12)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(appStorage.moodEntries.prefix(14)) { entry in
                                HStack {
                                    Text(formatDisplayDate(entry.dateString))
                                        .foregroundColor(.appTextSecondary)
                                    Spacer()
                                    Text(entry.mood.label)
                                        .foregroundColor(.appTextPrimary)
                                }
                                .padding(12)
                                if entry.id != appStorage.moodEntries.prefix(14).last?.id {
                                    Divider().background(Color.appTextSecondary.opacity(0.3))
                                }
                            }
                        }
                        .subtleCard(cornerRadius: 12)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Mood Diary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedMood = todayMood
        }
    }

    private func formatDisplayDate(_ s: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: s) else { return s }
        let out = DateFormatter()
        out.dateStyle = .medium
        return out.string(from: d)
    }
}

struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mood.label)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(isSelected ? .white : .appTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    (isSelected
                     ? LinearGradient(
                        colors: [Color.appPrimary, Color.appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                     )
                     : LinearGradient(
                        colors: [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                     )),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .shadow(color: Color.black.opacity(isSelected ? 0.3 : 0.15), radius: isSelected ? 8 : 4, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MoodDiaryView()
            .environmentObject(AppStorage.shared)
    }
}
