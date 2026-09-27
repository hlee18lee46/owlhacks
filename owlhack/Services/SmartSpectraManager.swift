import SwiftUI
import Combine
import AVFoundation
import SmartSpectra

@MainActor
final class SmartSpectraManager: ObservableObject {

    static let shared = SmartSpectraManager()

    // MARK: - SDK

    private let sdk = SmartSpectraSDK.shared

    // MARK: - Published Values

    @Published var pulseRateBuffer: [MeasurementWithConfidence] = []
    @Published var breathingRateBuffer: [MeasurementWithConfidence] = []

    @Published var pulseRate: Double?
    @Published var breathingRate: Double?

    // MARK: - Init

    private init() {

        sdk.config.apiKey = "your key"

        sdk.config.cameraPosition = .front

        sdk.config.imageOutputEnabled = true

        sdk.config.requestedMetrics =
            SmartSpectraConfig.breathingMetrics +
            SmartSpectraConfig.cardioMetrics

        sdk.config.logLevel = .info
    }

    // MARK: - Metrics

    var metrics: Metrics? {
        sdk.metrics
    }

    // MARK: - Camera Image

    var image: UIImage? {
        sdk.imageOutput
    }

    // MARK: - Metrics Update Token

    var metricsUpdateToken: Int64 {

        let pulseTimestamp =
            metrics?
                .cardio
                .pulseRate
                .last?
                .timestamp

        let breathingTimestamp =
            metrics?
                .breathing
                .rate
                .last?
                .timestamp

        return [
            pulseTimestamp,
            breathingTimestamp
        ]
        .compactMap { $0 }
        .max() ?? 0
    }

    // MARK: - Running

    var isRunning: Bool {

        sdk.processingStatus == .running ||
        sdk.processingStatus == .starting
    }

    // MARK: - Status

    var statusText: String {

        switch sdk.processingStatus {

        case .idle:
            return "Idle"

        case .starting:
            return "Starting"

        case .running:
            return "Running"

        case .stopping:
            return "Stopping"

        case .error:
            return "Error"

        @unknown default:
            return "Unknown"
        }
    }

    // MARK: - Validation

    var validationText: String {

        guard let validation =
                sdk.validationStatus else {

            return "Waiting"
        }

        switch validation.code {

        case .ok:
            return "OK"

        case .noFaceFound:
            return "No Face"

        case .multipleFacesFound:
            return "Multiple Faces"

        case .faceNotCentered:
            return "Face Off Center"

        case .faceSizeOutOfRange:
            return "Face Size"

        case .tooDark:
            return "Too Dark"

        case .tooBright:
            return "Too Bright"

        case .chestNotVisible:
            return "Chest Not Visible"

        case .cameraTuning:
            return "Camera Tuning"

        @unknown default:
            return "Unknown"
        }
    }

    // MARK: - Merge Current Metrics

    func mergeCurrentMetrics() {

        guard let currentMetrics =
                sdk.metrics else {

            return
        }

        // MARK: Heart Rate

        if !currentMetrics
            .cardio
            .pulseRate
            .isEmpty {

            pulseRateBuffer
                .appendProtoArray(
                    contentsOf:
                        currentMetrics
                            .cardio
                            .pulseRate
                )

            pulseRateBuffer =
                Array(
                    pulseRateBuffer
                        .suffix(120)
                )

            if let last =
                pulseRateBuffer.last {
                pulseRate = Double(last.value)
            }
        }

        // MARK: Breathing Rate

        if !currentMetrics
            .breathing
            .rate
            .isEmpty {

            breathingRateBuffer
                .appendProtoArray(
                    contentsOf:
                        currentMetrics
                            .breathing
                            .rate
                )

            breathingRateBuffer =
                Array(
                    breathingRateBuffer
                        .suffix(120)
                )

            if let last =
                breathingRateBuffer.last {
                breathingRate = Double(last.value)

            }
        }
    }

    // MARK: - Start Measurement

    func startMeasurement() async throws {

        // Clear previous measurement

        pulseRateBuffer.removeAll()

        breathingRateBuffer.removeAll()

        pulseRate = nil

        breathingRate = nil

        // Start SmartSpectra

        try await sdk.start()
    }

    // MARK: - Stop Measurement

    func stopMeasurement() async throws {

        try await sdk.stop()
    }
}
