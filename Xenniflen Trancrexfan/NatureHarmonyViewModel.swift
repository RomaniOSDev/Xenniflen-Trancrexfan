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

final class NatureHarmonyViewModel: ObservableObject {
    @Published var elements: [PlantElement] = []
    @Published var isComplete = false
    @Published var startTime: Date?
    let level: ActivityLevel
    let elementCount: Int
    private var dragStartPosition: [UUID: CGPoint] = [:]

    init(level: ActivityLevel) {
        self.level = level
        switch level {
        case .easy: elementCount = 5
        case .normal: elementCount = 8
        case .hard: elementCount = 12
        }
        setupElements()
    }

    private func setupElements() {
        elements = (0..<elementCount).map { i in
            let randomStart: CGPoint
            if level == .hard {
                randomStart = CGPoint(
                    x: CGFloat.random(in: 50...250),
                    y: CGFloat.random(in: 100...400)
                )
            } else {
                randomStart = CGPoint(x: 80 + CGFloat(i) * 30, y: 150 + CGFloat(i % 2) * 60)
            }
            return PlantElement(id: UUID(), position: randomStart, isPlaced: false)
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
