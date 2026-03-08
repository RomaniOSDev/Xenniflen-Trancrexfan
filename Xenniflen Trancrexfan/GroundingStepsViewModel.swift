//
//  GroundingStepsViewModel.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

struct GroundingStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

final class GroundingStepsViewModel: ObservableObject {
    @Published var steps: [GroundingStep] = []
    @Published var currentIndex: Int = 0
    @Published var completed: Bool = false
    @Published var startTime: Date?
    let level: ActivityLevel

    init(level: ActivityLevel) {
        self.level = level
        configureSteps()
    }

    private func configureSteps() {
        var base: [GroundingStep] = [
            GroundingStep(title: "Notice 5 sights", detail: "Look around and gently name five things you can see."),
            GroundingStep(title: "Notice 4 sounds", detail: "Listen for four different sounds, near or far."),
            GroundingStep(title: "Notice 3 touches", detail: "Pay attention to three things you can feel, like fabric or the ground."),
            GroundingStep(title: "Notice 2 scents", detail: "If possible, notice two scents around you, even if they are very subtle."),
            GroundingStep(title: "Notice 1 breath", detail: "Rest your attention on one slow, full breath.")
        ]
        switch level {
        case .easy:
            steps = Array(base.prefix(3))
        case .normal:
            steps = Array(base.prefix(4))
        case .hard:
            steps = base
        }
        startTime = Date()
    }

    func advance() {
        guard !completed else { return }
        if currentIndex < steps.count - 1 {
            currentIndex += 1
        } else {
            completed = true
        }
    }

    var durationSeconds: Double {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func starsEarned() -> Int {
        guard completed else { return 1 }
        let totalSeconds = durationSeconds
        // Reward a bit more presence for slower pace, but still give stars if quicker
        switch level {
        case .easy:
            if totalSeconds >= 90 { return 3 }
            if totalSeconds >= 45 { return 2 }
        case .normal:
            if totalSeconds >= 150 { return 3 }
            if totalSeconds >= 80 { return 2 }
        case .hard:
            if totalSeconds >= 210 { return 3 }
            if totalSeconds >= 120 { return 2 }
        }
        return 1
    }
}

