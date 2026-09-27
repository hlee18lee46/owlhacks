import SwiftUI
import Combine

@MainActor
final class WhatTheHootState: ObservableObject {

    // MARK: - Vitals

    @Published var heartRate: Double?
    @Published var breathingRate: Double?

    // MARK: - Gamification

    @Published var companion: String = "Smiley Owl"
    @Published var mood: String = "Chill"
    @Published var energy: String = "Balanced"

    // MARK: - Selfie

    @Published var selfie: UIImage?

    // MARK: - NFT

    @Published var nftMintAddress: String?
    @Published var nftExplorerURL: String?

    // MARK: - Wallet

    @Published var recipientWallet: String =
        "FVD73Wwq1WUa3v6Dya5Ph6jW1B45uN5bKU6h744qg2Gy"

    // MARK: - Update Vitals

    func updateVitals(
        heartRate: Double?,
        breathingRate: Double?
    ) {
        self.heartRate = heartRate
        self.breathingRate = breathingRate

        determineCompanion()
    }

    // MARK: - Gamification

    private func determineCompanion() {

        guard let heartRate,
              let breathingRate else {
            return
        }

        // Gamification only — not a medical classification.
        if heartRate < 70 && breathingRate < 16 {

            companion = "Chill Owl"
            mood = "Chill"
            energy = "Calm"

        } else if heartRate > 90 || breathingRate > 20 {

            companion = "Hype Owl"
            mood = "Excited"
            energy = "High"

        } else {

            companion = "Smiley Owl"
            mood = "Happy"
            energy = "Balanced"
        }
    }

    // MARK: - Reset

    func reset() {

        heartRate = nil
        breathingRate = nil

        companion = "Smiley Owl"
        mood = "Chill"
        energy = "Balanced"

        selfie = nil

        nftMintAddress = nil
        nftExplorerURL = nil
    }
}
