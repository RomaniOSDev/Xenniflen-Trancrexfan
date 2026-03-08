//
//  FocusTimerView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMinutes = 5
    @State private var isRunning = false
    @State private var remainingSeconds: Int = 0
    @State private var showResult = false
    @State private var timerTask: Task<Void, Never>?

    private let options = [5, 10, 15]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if !isRunning && remainingSeconds == 0 {
                setupView
            } else {
                timerView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timerTask?.cancel()
        }
        .fullScreenCover(isPresented: $showResult) {
            FocusResultView(
                minutesCompleted: selectedMinutes,
                onDone: {
                    showResult = false
                    dismiss()
                }
            )
            .environmentObject(appStorage)
        }
    }

    private var setupView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Focus Timer")
                    .font(.title.bold())
                    .foregroundColor(.appTextPrimary)

                Text("Choose duration for a quiet focus session.")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    ForEach(options, id: \.self) { min in
                        Button(action: { selectedMinutes = min }) {
                            Text("\(min) min")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(selectedMinutes == min ? .white : .appTextPrimary)
                                .frame(width: 72, height: 44)
                                .background(
                                    optionBackground(isSelected: selectedMinutes == min),
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                                .shadow(color: Color.black.opacity(selectedMinutes == min ? 0.3 : 0.18), radius: selectedMinutes == min ? 10 : 6, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 16)

                Button(action: startTimer) {
                    Text("Start")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .primaryButtonBackground(cornerRadius: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .padding(24)
        }
    }

    private var timerView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.appTextSecondary.opacity(0.3), lineWidth: 8)
                    .frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remainingSeconds)

                Text(timeFormatted)
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextPrimary)
            }

            if isRunning {
                Button(action: pauseTimer) {
                    Text("Pause")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 120, height: 44)
                }
                .frame(minWidth: 44, minHeight: 44)
            } else {
                HStack(spacing: 16) {
                    Button(action: resumeTimer) {
                        Text("Resume")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .primaryButtonBackground(cornerRadius: 12)
                    }
                    Button(action: cancelTimer) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                            .frame(width: 100, height: 44)
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(24)
    }

    private var progress: CGFloat {
        let total = selectedMinutes * 60
        guard total > 0 else { return 0 }
        return CGFloat(total - remainingSeconds) / CGFloat(total)
    }

    private func optionBackground(isSelected: Bool) -> LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [Color.appPrimary, Color.appAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var timeFormatted: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        remainingSeconds = selectedMinutes * 60
        isRunning = true
        runTimer()
    }

    private func pauseTimer() {
        isRunning = false
        timerTask?.cancel()
    }

    private func resumeTimer() {
        isRunning = true
        runTimer()
    }

    private func cancelTimer() {
        timerTask?.cancel()
        remainingSeconds = 0
        isRunning = false
    }

    private func runTimer() {
        timerTask = Task { @MainActor in
            while remainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    remainingSeconds -= 1
                    if remainingSeconds <= 0 {
                        isRunning = false
                        appStorage.recordFocusCompletion(minutes: selectedMinutes)
                        appStorage.addPlayTime(seconds: Double(selectedMinutes * 60))
                        showResult = true
                        break
                    }
                }
            }
        }
    }
}

struct FocusResultView: View {
    @EnvironmentObject var appStorage: AppStorage
    let minutesCompleted: Int
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.appPrimary)
                Text("Session complete")
                    .font(.title2.bold())
                    .foregroundColor(.appTextPrimary)
                Text("\(minutesCompleted) minutes of focus")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                Text("You earned 1 star")
                    .font(.subheadline)
                    .foregroundColor(.appAccent)
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .primaryButtonBackground(cornerRadius: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
            .padding(24)
            .elevatedCard(cornerRadius: 20)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        FocusTimerView()
            .environmentObject(AppStorage.shared)
    }
}
