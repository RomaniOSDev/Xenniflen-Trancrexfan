//
//  ArtisticExpressionViewModel.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import Combine

struct StrokePoint: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var colorIndex: Int
    var lineWidth: CGFloat
    var isErase: Bool
}

final class ArtisticExpressionViewModel: ObservableObject {
    @Published var strokes: [StrokePoint] = []
    @Published var currentStroke: [CGPoint] = []
    @Published var currentColor: Color = .appPrimary
    @Published var brushSize: CGFloat = 8
    @Published var isErase = false
    @Published var textureMode: Int = 0
    @Published var startTime: Date?
    let level: ActivityLevel
    let colors: [Color]
    let brushSizes: [CGFloat]

    init(level: ActivityLevel) {
        self.level = level
        switch level {
        case .easy:
            colors = [Color.appPrimary, Color.appAccent, Color.appTextPrimary]
            brushSizes = [6, 12]
        case .normal:
            colors = [Color.appPrimary, Color.appAccent, Color.appTextPrimary, Color.appSurface, Color.appBackground]
            brushSizes = [4, 8, 16]
        case .hard:
            colors = [Color.appPrimary, Color.appAccent, Color.appTextPrimary, Color.appSurface, Color.appBackground, Color.appPrimary.opacity(0.7)]
            brushSizes = [2, 6, 10, 18]
        }
        startTime = Date()
    }

    func addPoint(_ point: CGPoint) {
        currentStroke.append(point)
    }

    func endStroke() {
        guard !currentStroke.isEmpty else { return }
        let idx = colors.firstIndex(where: { $0 == currentColor }) ?? 0
        strokes.append(StrokePoint(
            points: currentStroke,
            color: currentColor,
            colorIndex: idx,
            lineWidth: brushSize,
            isErase: isErase
        ))
        currentStroke = []
    }

    func clear() {
        strokes = []
        currentStroke = []
    }

    func calculateStars() -> Int {
        let uniqueColors = Set(strokes.filter { !$0.isErase }.map { $0.colorIndex }).count
        let totalPoints = strokes.reduce(0) { $0 + $1.points.count }
        if totalPoints >= 50 && uniqueColors >= 3 { return 3 }
        if totalPoints >= 20 && uniqueColors >= 2 { return 2 }
        if totalPoints >= 5 { return 1 }
        return 0
    }

    var durationSeconds: Double {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func reset() {
        strokes = []
        currentStroke = []
        startTime = Date()
    }
}
