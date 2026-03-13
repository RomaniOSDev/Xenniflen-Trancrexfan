//
//  AppStorage.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

extension Notification.Name {
    static let appStorageDidReset = Notification.Name("appStorageDidReset")
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let dateString: String
    let mood: MoodType
    init(id: UUID = UUID(), dateString: String, mood: MoodType) {
        self.id = id
        self.dateString = dateString
        self.mood = mood
    }
}

enum MoodType: String, CaseIterable, Codable {
    case calm
    case energized
    case peaceful
    case tired
    case balanced
    var label: String {
        switch self {
        case .calm: return "Calm"
        case .energized: return "Energized"
        case .peaceful: return "Peaceful"
        case .tired: return "Tired"
        case .balanced: return "Balanced"
        }
    }
}

struct DayStats: Codable {
    var stars: Int
    var activitiesCount: Int
    var focusMinutes: Int
    init(stars: Int = 0, activitiesCount: Int = 0, focusMinutes: Int = 0) {
        self.stars = stars
        self.activitiesCount = activitiesCount
        self.focusMinutes = focusMinutes
    }
}

final class AppStorage: ObservableObject {
    static let shared = AppStorage()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let savedSoundscapes = "savedSoundscapes"
        static let moodEntries = "moodEntries"
        static let dayStats = "dayStats"
        static let focusTimerCompletions = "focusTimerCompletions"
        static let focusMinutesTotal = "focusMinutesTotal"
        static let savedDrawings = "savedDrawings"
        static let guidedDrawingsCompleted = "guidedDrawingsCompleted"
        static let breathingProgramProgress = "breathingProgramProgress"
        static let focusProgramProgress = "focusProgramProgress"
        static let groundingProgramProgress = "groundingProgramProgress"
        static let gratitudeProgramProgress = "gratitudeProgramProgress"
        static func stars(activity: Int, level: String) -> String {
            "stars_\(activity)_\(level)"
        }
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalPlayTimeSeconds: Double {
        didSet { defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds) }
    }

    @Published var totalActivitiesPlayed: Int {
        didSet { defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published var focusTimerCompletions: Int {
        didSet { defaults.set(focusTimerCompletions, forKey: Keys.focusTimerCompletions) }
    }

    @Published var focusMinutesTotal: Int {
        didSet { defaults.set(focusMinutesTotal, forKey: Keys.focusMinutesTotal) }
    }

    @Published var guidedDrawingsCompleted: Int {
        didSet { defaults.set(guidedDrawingsCompleted, forKey: Keys.guidedDrawingsCompleted) }
    }

    init() {
        self.hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        self.totalPlayTimeSeconds = defaults.double(forKey: Keys.totalPlayTimeSeconds)
        self.totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        self.focusTimerCompletions = defaults.integer(forKey: Keys.focusTimerCompletions)
        self.focusMinutesTotal = defaults.integer(forKey: Keys.focusMinutesTotal)
        self.guidedDrawingsCompleted = defaults.integer(forKey: Keys.guidedDrawingsCompleted)
    }

    func stars(activity: Int, level: ActivityLevel) -> Int {
        let key = Keys.stars(activity: activity, level: level.rawValue)
        return defaults.integer(forKey: key)
    }

    func setStars(_ value: Int, activity: Int, level: ActivityLevel) {
        let key = Keys.stars(activity: activity, level: level.rawValue)
        defaults.set(value, forKey: key)
        objectWillChange.send()
    }

    var totalStars: Int {
        ActivityKind.allCases.reduce(0) { sum, kind in
            sum + ActivityLevel.allCases.reduce(0) { s, level in
                s + stars(activity: kind.rawValue, level: level)
            }
        }
    }

    func isLevelUnlocked(level: ActivityLevel) -> Bool {
        switch level {
        case .easy: return true
        case .normal: return totalStars >= 3
        case .hard: return totalStars >= 9
        }
    }

    func addPlayTime(seconds: Double) {
        totalPlayTimeSeconds += seconds
    }

    func incrementActivitiesPlayed() {
        totalActivitiesPlayed += 1
    }

    func recordActivityCompletion(starsEarned: Int) {
        let key = todayKey()
        var stats = loadDayStats()[key] ?? DayStats()
        stats.stars += starsEarned
        stats.activitiesCount += 1
        saveDayStats(key: key, stats: stats)
        objectWillChange.send()
    }

    func recordFocusCompletion(minutes: Int) {
        focusTimerCompletions += 1
        focusMinutesTotal += minutes
        let key = todayKey()
        var stats = loadDayStats()[key] ?? DayStats()
        stats.focusMinutes += minutes
        saveDayStats(key: key, stats: stats)
        objectWillChange.send()
    }

    private func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func loadDayStats() -> [String: DayStats] {
        guard let data = defaults.data(forKey: Keys.dayStats),
              let decoded = try? JSONDecoder().decode([String: DayStats].self, from: data) else { return [:] }
        return decoded
    }

    private func saveDayStats(key: String, stats: DayStats) {
        var all = loadDayStats()
        all[key] = stats
        if let data = try? JSONEncoder().encode(all) {
            defaults.set(data, forKey: Keys.dayStats)
        }
    }

    var moodEntries: [MoodEntry] {
        get {
            guard let data = defaults.data(forKey: Keys.moodEntries),
                  let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) else { return [] }
            return decoded.sorted { $0.dateString > $1.dateString }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.moodEntries)
                objectWillChange.send()
            }
        }
    }

    func addMoodEntry(_ entry: MoodEntry) {
        var list = moodEntries
        list.removeAll { $0.dateString == entry.dateString }
        list.append(entry)
        moodEntries = list
    }

    func moodForDate(_ dateString: String) -> MoodType? {
        moodEntries.first { $0.dateString == dateString }?.mood
    }

    func dominantMoodLastDays(_ days: Int = 7) -> MoodType? {
        guard !moodEntries.isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let now = Date()
        let fromDate = cal.date(byAdding: .day, value: -days + 1, to: now) ?? now
        var counts: [MoodType: Int] = [:]
        for entry in moodEntries {
            guard let d = f.date(from: entry.dateString) else { continue }
            if d >= fromDate && d <= now {
                counts[entry.mood, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var recommendationText: String? {
        let focusLow = thisWeekSummary.focusMinutes < 10
        let dominant = dominantMoodLastDays()
        if focusLow {
            return "Your focus time is low this week. Try a short Focus Timer or Grounding Steps session today."
        }
        if let mood = dominant {
            switch mood {
            case .tired:
                return "You often felt Tired recently. A gentle Mindful Journey or Nature's Harmony scene may help you unwind."
            case .energized:
                return "You felt Energized this week. Explore Artistic Expression to channel that energy creatively."
            case .calm:
                return "Calm has been present in your recent days. Sustain it with a brief breathing session."
            case .peaceful:
                return "Your recent mood was Peaceful. Try a Gratitude Flow to deepen that feeling."
            case .balanced:
                return "You seem quite Balanced. Choose any activity that matches your current intention."
            }
        }
        return nil
    }

    var savedDrawings: [Data] {
        get {
            defaults.array(forKey: Keys.savedDrawings) as? [Data] ?? []
        }
        set {
            defaults.set(newValue, forKey: Keys.savedDrawings)
            objectWillChange.send()
        }
    }

    func addDrawing(_ data: Data) {
        var all = savedDrawings
        all.insert(data, at: 0)
        if all.count > 24 {
            all = Array(all.prefix(24))
        }
        savedDrawings = all
    }

    enum WellnessProgram: String, CaseIterable {
        case breathing
        case focus
        case grounding
        case gratitude

        var targetSessions: Int {
            switch self {
            case .breathing: return 5
            case .focus: return 5
            case .grounding: return 7
            case .gratitude: return 5
            }
        }
    }

    func programProgress(_ program: WellnessProgram) -> Int {
        switch program {
        case .breathing:
            return defaults.integer(forKey: Keys.breathingProgramProgress)
        case .focus:
            return defaults.integer(forKey: Keys.focusProgramProgress)
        case .grounding:
            return defaults.integer(forKey: Keys.groundingProgramProgress)
        case .gratitude:
            return defaults.integer(forKey: Keys.gratitudeProgramProgress)
        }
    }

    func incrementProgramProgress(_ program: WellnessProgram) {
        let current = programProgress(program)
        let next = min(current + 1, program.targetSessions)
        switch program {
        case .breathing:
            defaults.set(next, forKey: Keys.breathingProgramProgress)
        case .focus:
            defaults.set(next, forKey: Keys.focusProgramProgress)
        case .grounding:
            defaults.set(next, forKey: Keys.groundingProgramProgress)
        case .gratitude:
            defaults.set(next, forKey: Keys.gratitudeProgramProgress)
        }
        objectWillChange.send()
    }

    struct WeekSummary {
        let stars: Int
        let activities: Int
        let focusMinutes: Int
    }

    func weekSummary(for date: Date) -> WeekSummary {
        let cal = Calendar.current
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return WeekSummary(stars: 0, activities: 0, focusMinutes: 0)
        }
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) ?? date
        var stars = 0, activities = 0, focusMinutes = 0
        let all = loadDayStats()
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        for (key, stats) in all {
            guard let d = f.date(from: key) else { continue }
            if d >= weekStart && d < weekEnd {
                stars += stats.stars
                activities += stats.activitiesCount
                focusMinutes += stats.focusMinutes
            }
        }
        return WeekSummary(stars: stars, activities: activities, focusMinutes: focusMinutes)
    }

    var thisWeekSummary: WeekSummary { weekSummary(for: Date()) }
    var lastWeekSummary: WeekSummary {
        let cal = Calendar.current
        let lastWeek = cal.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return weekSummary(for: lastWeek)
    }

    var totalPlayTimeFormatted: String {
        let total = Int(totalPlayTimeSeconds)
        let min = total / 60
        let sec = total % 60
        if min > 0 {
            return "\(min) min \(sec) sec"
        }
        return "\(sec) sec"
    }

    var achievements: [Achievement] {
        var list: [Achievement] = []
        if totalActivitiesPlayed >= 1 {
            list.append(Achievement(id: "first_steps", title: "First Steps", description: "Complete your first activity"))
        }
        if totalStars >= 5 {
            list.append(Achievement(id: "star_collector", title: "Star Collector", description: "Earn 5 stars"))
        }
        if totalStars >= 15 {
            list.append(Achievement(id: "rising_star", title: "Rising Star", description: "Earn 15 stars"))
        }
        if totalPlayTimeSeconds >= 600 {
            list.append(Achievement(id: "dedicated", title: "Dedicated", description: "Spend 10 minutes in activities"))
        }
        if totalActivitiesPlayed >= 10 {
            list.append(Achievement(id: "explorer", title: "Explorer", description: "Complete 10 activities"))
        }
        if hasCompletedAllLevels {
            list.append(Achievement(id: "all_levels", title: "All Levels", description: "Complete Easy, Normal and Hard in one activity"))
        }
        if hasThreeActivitiesInOneDay {
            list.append(Achievement(id: "three_in_one_day", title: "Triple Finish", description: "Complete 3 activities in one day"))
        }
        if focusTimerCompletions >= 5 {
            list.append(Achievement(id: "focus_master", title: "Focus Master", description: "Complete 5 focus timer sessions"))
        }
        if hasWeekWithTenStars {
            list.append(Achievement(id: "weekly_hero", title: "Weekly Hero", description: "Earn 10 or more stars in one week"))
        }
        if hasSevenDaysWithActivity {
            list.append(Achievement(id: "first_week", title: "First Week", description: "Use the app on 7 different days"))
        }
        return list
    }

    private var hasCompletedAllLevels: Bool {
        for kind in ActivityKind.allCases {
            let id = kind.rawValue
            let hasEasy = stars(activity: id, level: .easy) > 0
            let hasNormal = stars(activity: id, level: .normal) > 0
            let hasHard = stars(activity: id, level: .hard) > 0
            if hasEasy && hasNormal && hasHard { return true }
        }
        return false
    }

    private var hasThreeActivitiesInOneDay: Bool {
        loadDayStats().values.contains { $0.activitiesCount >= 3 }
    }

    private var hasWeekWithTenStars: Bool {
        thisWeekSummary.stars >= 10 || lastWeekSummary.stars >= 10 ||
        weekSummary(for: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date()).stars >= 10
    }

    private var hasSevenDaysWithActivity: Bool {
        loadDayStats().filter { $0.value.activitiesCount > 0 || $0.value.focusMinutes > 0 }.count >= 7
    }

    func resetAll() {
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.totalPlayTimeSeconds)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.savedSoundscapes)
        defaults.removeObject(forKey: Keys.moodEntries)
        defaults.removeObject(forKey: Keys.dayStats)
        defaults.removeObject(forKey: Keys.focusTimerCompletions)
        defaults.removeObject(forKey: Keys.focusMinutesTotal)
        for kind in ActivityKind.allCases {
            for level in ActivityLevel.allCases {
                defaults.removeObject(forKey: Keys.stars(activity: kind.rawValue, level: level.rawValue))
            }
        }
        hasSeenOnboarding = false
        totalPlayTimeSeconds = 0
        totalActivitiesPlayed = 0
        focusTimerCompletions = 0
        focusMinutesTotal = 0
        objectWillChange.send()
        NotificationCenter.default.post(name: .appStorageDidReset, object: nil)
    }

    func saveSoundscapes(_ data: Data) {
        defaults.set(data, forKey: Keys.savedSoundscapes)
    }

    func loadSoundscapes() -> Data? {
        defaults.data(forKey: Keys.savedSoundscapes)
    }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case easy
    case normal
    case hard
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum ActivityKind: Int, CaseIterable, Identifiable {
    case natureHarmony = 1
    case artisticExpression = 2
    case mindfulJourney = 3
    case gratitudeFlow = 4
    case groundingSteps = 5
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .natureHarmony: return "Nature's Harmony"
        case .artisticExpression: return "Artistic Expression"
        case .mindfulJourney: return "Mindful Journey"
        case .gratitudeFlow: return "Gratitude Flow"
        case .groundingSteps: return "Grounding Steps"
        }
    }
}
