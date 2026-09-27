import SwiftUI

struct HomeView: View {

    @EnvironmentObject
    private var appState: WhatTheHootState

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 28) {

                    Spacer()
                        .frame(height: 20)

                    // MARK: Hero

                    VStack(spacing: 10) {

                        Text("🦉")
                            .font(
                                .system(size: 100)
                            )

                        Text("WhatTheHoot")
                            .font(
                                .system(
                                    size: 38,
                                    weight: .bold
                                )
                            )

                        Text(
                            "Your vitals. Your vibe. Your companion."
                        )
                        .font(.headline)
                        .foregroundStyle(
                            .secondary
                        )
                        .multilineTextAlignment(
                            .center
                        )
                    }

                    // MARK: How it works

                    VStack(spacing: 14) {

                        FeatureCard(
                            icon:
                                "heart.fill",

                            title:
                                "Check Your Vitals",

                            description:
                                "Use the camera to measure your heart rate and breathing rate."
                        )

                        FeatureCard(
                            icon:
                                "pawprint.fill",

                            title:
                                "Meet Your Companion",

                            description:
                                "Your readings power the game and reveal your WhatTheHoot companion."
                        )

                        FeatureCard(
                            icon:
                                "camera.fill",

                            title:
                                "Take a Selfie",

                            description:
                                "Take a photo with your companion and mint the moment as an NFT."
                        )
                    }

                    // MARK: Current companion

                    if appState.heartRate != nil {

                        VStack(spacing: 8) {

                            Text(
                                "YOUR COMPANION"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )

                            Text(
                                appState.companion
                            )
                            .font(.title2)
                            .bold()

                            Text(
                                "\(appState.mood) • \(appState.energy)"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity
                        )
                        .background(
                            .thinMaterial,
                            in:
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(
                "WhatTheHoot"
            )
        }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {

    let icon: String

    let title: String

    let description: String

    var body: some View {

        HStack(spacing: 18) {

            Image(systemName: icon)
                .font(
                    .system(size: 28)
                )
                .frame(width: 45)

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
            }

            Spacer()
        }
        .padding()
        .background(
            .thinMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 20
                )
        )
    }
}

#Preview {

    HomeView()
        .environmentObject(
            WhatTheHootState()
        )
}
