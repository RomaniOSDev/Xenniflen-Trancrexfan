//
//  SettingsView.swift
//  Xenniflen Trancrexfan
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Button(action: rateApp) {
                            SettingsRow(title: "Rate us", icon: "star.fill")
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legal")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Button(action: openPrivacyPolicy) {
                            SettingsRow(title: "Privacy", icon: "hand.raised.fill")
                        }
                        .buttonStyle(.plain)
                        Button(action: openTerms) {
                            SettingsRow(title: "Terms", icon: "doc.text.fill")
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Onboarding")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Button(action: showOnboardingAgain) {
                            SettingsRow(title: "View onboarding again", icon: "rectangle.stack.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://xenniflentrancrexfan101.site/privacy/33") {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = URL(string: "https://xenniflentrancrexfan101.site/terms/33") {
            UIApplication.shared.open(url)
        }
    }

    private func showOnboardingAgain() {
        appStorage.hasSeenOnboarding = false
        dismiss()
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .frame(width: 24, alignment: .center)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .padding(12)
        .subtleCard(cornerRadius: 12)
        .frame(minHeight: 44)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppStorage.shared)
    }
}
