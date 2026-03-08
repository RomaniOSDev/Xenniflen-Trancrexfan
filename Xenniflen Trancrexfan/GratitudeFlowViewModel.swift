//
//  GratitudeFlowViewModel.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

struct GratitudePrompt: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

final class GratitudeFlowViewModel: ObservableObject {
    @Published var prompts: [GratitudePrompt] = []
    @Published var selected: Set<GratitudePrompt> = []
    @Published var startTime: Date?
    let level: ActivityLevel

    init(level: ActivityLevel) {
        self.level = level
        configurePrompts()
    }

    private func configurePrompts() {
        let base: [String] = [
            "A calm moment you enjoyed recently",
            "Someone who supported you today",
            "A place that makes you feel grounded",
            "A small thing that made you smile",
            "A habit that helps you slow down",
            "A sound that feels soothing",
            "Something you created this week",
            "A decision you feel good about"
        ]
        let count: Int
        switch level {
        case .easy: count = 4
        case .normal: count = 6
        case .hard: count = 8
        }
        let slice = Array(base.prefix(count))
        prompts = slice.map { GratitudePrompt(text: $0) }
        startTime = Date()
    }

    func toggle(_ prompt: GratitudePrompt) {
        if selected.contains(prompt) {
            selected.remove(prompt)
        } else {
            selected.insert(prompt)
        }
    }

    var durationSeconds: Double {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func starsEarned() -> Int {
        let ratio = Double(selected.count) / Double(prompts.count)
        if ratio >= 0.75 { return 3 }
        if ratio >= 0.4 { return 2 }
        return selected.isEmpty ? 1 : 1
    }
}

