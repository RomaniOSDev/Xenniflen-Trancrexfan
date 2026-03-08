//
//  MindfulJourneyViewModel.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

enum BreathPhase {
    case inhale
    case hold
    case exhale
}

final class MindfulJourneyViewModel: ObservableObject {
    @Published var phase: BreathPhase = .inhale
    @Published var phaseProgress: CGFloat = 0
    @Published var isRunning = false
    @Published var isComplete = false
    @Published var startTime: Date?
    @Published var completedCycles = 0
    let level: ActivityLevel
    let cyclesToComplete: Int
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    private var timer: Timer?
    private var phaseStart: Date?

    init(level: ActivityLevel) {
        self.level = level
        switch level {
        case .easy:
            cyclesToComplete = 2
            inhaleSeconds = 3
            holdSeconds = 1
            exhaleSeconds = 3
        case .normal:
            cyclesToComplete = 3
            inhaleSeconds = 4
            holdSeconds = 2
            exhaleSeconds = 4
        case .hard:
            cyclesToComplete = 4
            inhaleSeconds = 4
            holdSeconds = 3
            exhaleSeconds = 5
        }
        startTime = Date()
    }

    func start() {
        isRunning = true
        isComplete = false
        phase = .inhale
        phaseProgress = 0
        phaseStart = Date()
        startTime = Date()
        completedCycles = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard let start = phaseStart else { return }
        let elapsed = Date().timeIntervalSince(start)
        let total: Double
        switch phase {
        case .inhale: total = inhaleSeconds
        case .hold: total = holdSeconds
        case .exhale: total = exhaleSeconds
        }
        if elapsed >= total {
            advancePhase()
            return
        }
        phaseProgress = CGFloat(elapsed / total)
    }

    private func advancePhase() {
        switch phase {
        case .inhale:
            phase = .hold
            phaseStart = Date()
            phaseProgress = 0
        case .hold:
            phase = .exhale
            phaseStart = Date()
            phaseProgress = 0
        case .exhale:
            completedCycles += 1
            if completedCycles >= cyclesToComplete {
                stop()
                isComplete = true
                return
            }
            phase = .inhale
            phaseStart = Date()
            phaseProgress = 0
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    var circleScale: CGFloat {
        switch phase {
        case .inhale: return 0.6 + 0.4 * phaseProgress
        case .hold: return 1.0
        case .exhale: return 1.0 - 0.4 * phaseProgress
        }
    }

    var phaseLabel: String {
        switch phase {
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        }
    }

    func calculateStars() -> Int {
        guard isComplete else { return 0 }
        switch level {
        case .easy: return completedCycles >= 2 ? 2 : 1
        case .normal: return completedCycles >= 3 ? 3 : (completedCycles >= 2 ? 2 : 1)
        case .hard: return completedCycles >= 4 ? 3 : (completedCycles >= 3 ? 2 : 1)
        }
    }

    var durationSeconds: Double {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func reset() {
        stop()
        phase = .inhale
        phaseProgress = 0
        isComplete = false
        completedCycles = 0
        startTime = Date()
    }
}
