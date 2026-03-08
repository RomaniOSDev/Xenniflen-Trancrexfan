//
//  View+Styling.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct ElevatedCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color.appSurface,
                        Color.appSurface.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 10)
    }
}

struct SubtleCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.95),
                        Color.appSurface.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}

struct PrimaryButtonModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.appPrimary, Color.appAccent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .shadow(color: Color.appPrimary.opacity(0.6), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func elevatedCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(ElevatedCardModifier(cornerRadius: cornerRadius))
    }

    func subtleCard(cornerRadius: CGFloat = 12) -> some View {
        modifier(SubtleCardModifier(cornerRadius: cornerRadius))
    }

    func primaryButtonBackground(cornerRadius: CGFloat = 12) -> some View {
        modifier(PrimaryButtonModifier(cornerRadius: cornerRadius))
    }
}

