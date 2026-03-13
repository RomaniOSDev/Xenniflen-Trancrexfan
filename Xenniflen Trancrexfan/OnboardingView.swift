//
//  OnboardingView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appStorage: AppStorage
    @State private var currentPage = 0
    @State private var shapePhase: CGFloat = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        pageIndex: 0,
                        title: "Welcome",
                        subtitle: "Enhance your daily well-being through relaxing activities that promote creativity and mindfulness.",
                        shapePhase: $shapePhase
                    )
                    .tag(0)
                    OnboardingPageView(
                        pageIndex: 1,
                        title: "Explore Activities",
                        subtitle: "Choose from nature soundscapes, artistic expression, and mindful meditation. Follow gentle prompts or guided tasks in each activity.",
                        shapePhase: $shapePhase
                    )
                    .tag(1)
                    OnboardingPageView(
                        pageIndex: 2,
                        title: "Collect Stars",
                        subtitle: "Earn stars by completing activities and following small programs. Weekly insights and suggestions on the home screen help you decide what to try next.",
                        shapePhase: $shapePhase
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: currentPage)

                PageIndicator(current: currentPage, total: 3)
                    .padding(.top, 24)

                Button(action: finishOnboarding) {
                    Text(currentPage == 2 ? "Get Started" : "Continue")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .primaryButtonBackground(cornerRadius: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                shapePhase = 1
            }
        }
    }

    private func finishOnboarding() {
        if currentPage < 2 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            appStorage.hasSeenOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let pageIndex: Int
    let title: String
    let subtitle: String
    @Binding var shapePhase: CGFloat

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    OnboardingShape(pageIndex: pageIndex, phase: shapePhase)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.4), Color.appAccent.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                }
                .frame(height: 220)
                .padding(.top, 48)

                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct OnboardingShape: Shape {
    var pageIndex: Int
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        switch pageIndex {
        case 0:
            return hexagonPath(in: rect)
        case 1:
            return circlePath(in: rect)
        default:
            return starPath(in: rect)
        }
    }

    private func hexagonPath(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 + Double(phase) * .pi * 0.5
            let x = center.x + r * CGFloat(cos(angle))
            let y = center.y + r * CGFloat(sin(angle))
            let point = CGPoint(x: x, y: y)
            if i == 0 { p.move(to: point) }
            else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }

    private func circlePath(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width, rect.height) / 2 * (0.7 + 0.3 * phase)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let box = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        p.addEllipse(in: box)
        return p
    }

    private func starPath(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for i in 0..<5 {
            let angle = Double(i) * .pi * 2 / 5 - .pi / 2 + Double(phase) * .pi * 0.3
            let x = center.x + r * CGFloat(cos(angle))
            let y = center.y + r * CGFloat(sin(angle))
            let point = CGPoint(x: x, y: y)
            if i == 0 { p.move(to: point) }
            else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }
}

struct PageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.appPrimary : Color.appTextSecondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(i == current ? 1.2 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppStorage.shared)
}
