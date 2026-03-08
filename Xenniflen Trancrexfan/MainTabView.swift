//
//  MainTabView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Discover", systemImage: "leaf.fill")
                }
                .tag(0)
            ActivitiesView()
                .tabItem {
                    Label("Activities", systemImage: "star.fill")
                }
                .tag(1)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(Color.appPrimary)
        .onReceive(NotificationCenter.default.publisher(for: .appStorageDidReset)) { _ in
            selectedTab = 0
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStorage.shared)
}
