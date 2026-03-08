//
//  ContentView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appStorage: AppStorage

    var body: some View {
        Group {
            if appStorage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: appStorage.hasSeenOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStorage.shared)
}
