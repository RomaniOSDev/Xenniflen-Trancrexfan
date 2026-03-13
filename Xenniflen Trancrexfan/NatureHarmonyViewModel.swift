//
//  NatureHarmonyViewModel.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

struct PlantElement: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var isPlaced: Bool
}

enum NatureHarmonyPreset: String, CaseIterable, Identifiable {
    case relax
    case focus
    case sleep
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .relax: return "Relax"
        case .focus: return "Focus"
        case .sleep: return "Sleep"
        }
    }
}

final class NatureHarmonyViewModel: ObservableObject {
    @Published var elements: [PlantElement] = []
    @Published var isComplete = false
    @Published var startTime: Date?
    let level: ActivityLevel
    let elementCount: Int
    let preset: NatureHarmonyPreset
    private var dragStartPosition: [UUID: CGPoint] = [:]

    init(level: ActivityLevel, preset: NatureHarmonyPreset) {
        self.level = level
        self.preset = preset
        switch level {
        case .easy: elementCount = 5
        case .normal: elementCount = 8
        case .hard: elementCount = 12
        }
        setupElements()
    }

    private func setupElements() {
        elements = (0..<elementCount).map { i in
            let baseX = CGFloat.random(in: 60...260)
            let baseY = CGFloat.random(in: 120...420)
            let position: CGPoint
            switch preset {
            case .relax:
                // Spread elements in a gentle arc
                let angle = Double(i) / Double(max(elementCount - 1, 1)) * Double.pi
                let radius: CGFloat = 110
                let center = CGPoint(x: 180, y: 260)
                position = CGPoint(
                    x: center.x + radius * CGFloat(cos(angle)),
                    y: center.y + radius * CGFloat(sin(angle)) * 0.4
                )
            case .focus:
                // Cluster elements near the center
                position = CGPoint(
                    x: 180 + CGFloat.random(in: -40...40),
                    y: 260 + CGFloat.random(in: -40...40)
                )
            case .sleep:
                // Elements start lower on the canvas, drifting downwards
                position = CGPoint(
                    x: baseX,
                    y: baseY + CGFloat.random(in: 40...80)
                )
            }
            return PlantElement(id: UUID(), position: position, isPlaced: false)
        }
        startTime = Date()
        dragStartPosition = [:]
    }

    func hasDragStart(for id: UUID) -> Bool {
        dragStartPosition[id] != nil
    }

    func beginDrag(id: UUID) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        dragStartPosition[id] = elements[idx].position
    }

    func updateDrag(id: UUID, translation: CGSize) {
        guard let start = dragStartPosition[id] else { return }
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        elements[idx].position = CGPoint(x: start.x + translation.width, y: start.y + translation.height)
        elements[idx].isPlaced = true
        checkCompletion()
    }

    func endDrag(id: UUID, translation: CGSize) {
        guard let start = dragStartPosition[id] else { return }
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        elements[idx].position = CGPoint(x: start.x + translation.width, y: start.y + translation.height)
        elements[idx].isPlaced = true
        dragStartPosition[id] = nil
        checkCompletion()
    }

    func updatePosition(id: UUID, position: CGPoint) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        elements[idx].position = position
        elements[idx].isPlaced = true
        checkCompletion()
    }

    private func checkCompletion() {
        let allPlaced = elements.allSatisfy { $0.isPlaced }
        if allPlaced && !isComplete {
            isComplete = true
        }
    }

    func calculateStars(canvasSize: CGSize) -> Int {
        guard isComplete else { return 0 }
        let bounds = CGRect(origin: .zero, size: canvasSize).insetBy(dx: 20, dy: 20)
        let allInBounds = elements.allSatisfy { bounds.contains($0.position) }
        let spread = spreadScore()
        if allInBounds && spread > 0.6 { return 3 }
        if allInBounds || spread > 0.4 { return 2 }
        return 1
    }

    private func spreadScore() -> Double {
        guard elements.count >= 2 else { return 1 }
        var minDist: CGFloat = 1000
        for i in 0..<elements.count {
            for j in (i+1)..<elements.count {
                let d = hypot(elements[i].position.x - elements[j].position.x, elements[i].position.y - elements[j].position.y)
                if d < minDist { minDist = d }
            }
        }
        let avgDist: CGFloat = 60
        return min(1, Double(minDist / avgDist))
    }

    var durationSeconds: Double {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func reset() {
        setupElements()
        isComplete = false
    }
}
