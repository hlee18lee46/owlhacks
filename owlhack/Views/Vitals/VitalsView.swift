import SwiftUI
import SmartSpectra


// MARK: - Cortex Response

private struct CortexResponse: Decodable {
    let success: Bool
    let heartRate: Double?
    let breathingRate: Double?
    let summary: String?
    let error: String?
    let details: String?
}


// MARK: - Vitals View

struct VitalsView: View {

    // MARK: - Shared App State

    @EnvironmentObject
    private var appState: WhatTheHootState


    // MARK: - SmartSpectra

    @StateObject
    private var manager = SmartSpectraManager.shared


    // MARK: - Error State

    @State
    private var measurementError: String?


    // MARK: - Cortex State

    @State
    private var cortexAnalysis: String?

    @State
    private var cortexError: String?

    @State
    private var isLoadingAnalysis = false


    // MARK: - Display Values

    private var pulseText: String {
        guard let value = manager.pulseRate else {
            return "--"
        }

        return "\(Int(value.rounded()))"
    }


    private var breathingText: String {
        guard let value = manager.breathingRate else {
            return "--"
        }

        return "\(Int(value.rounded()))"
    }


    // MARK: - Pulse Status

    private var pulseStatus: VitalStatus {
        guard let pulse = manager.pulseRate else {
            return .unknown
        }

        if pulse < 60 {
            return .low
        }

        if pulse > 100 {
            return .high
        }

        return .normal
    }


    // MARK: - Breathing Status

    private var breathingStatus: VitalStatus {
        guard let breathing = manager.breathingRate else {
            return .unknown
        }

        if breathing < 12 {
            return .low
        }

        if breathing > 20 {
            return .high
        }

        return .normal
    }


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    // MARK: Status

                    HStack(spacing: 30) {

                        VStack(spacing: 4) {

                            Text("STATUS")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(manager.statusText)
                                .font(.headline)
                        }


                        VStack(spacing: 4) {

                            Text("VALIDATION")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(manager.validationText)
                                .font(.headline)
                        }
                    }


                    // MARK: Camera Preview

                    ZStack {

                        RoundedRectangle(
                            cornerRadius: 20
                        )
                        .fill(.black)


                        if let image = manager.image {

                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(
                                    contentMode: .fill
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .clipped()

                        } else {

                            VStack(spacing: 12) {

                                Image(
                                    systemName: "camera.viewfinder"
                                )
                                .font(
                                    .system(size: 45)
                                )


                                Text("Camera Preview")
                                    .font(.headline)


                                Text("Press Start Measurement")
                                    .font(.caption)
                            }
                            .foregroundStyle(.white)
                        }
                    }
                    .frame(height: 360)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )


                    // MARK: Live Vitals

                    HStack(spacing: 60) {

                        VitalValueView(
                            emoji: "❤️",
                            value: pulseText,
                            unit: "BPM"
                        )


                        VitalValueView(
                            emoji: "🌬️",
                            value: breathingText,
                            unit: "Breaths/min"
                        )
                    }


                    Text(
                        "Keep your face and upper chest visible"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)


                    // MARK: Measurement Error

                    if let measurementError {

                        HStack(spacing: 8) {

                            Image(
                                systemName:
                                    "exclamationmark.triangle.fill"
                            )

                            Text(measurementError)
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding()
                        .background(
                            Color.red.opacity(0.08),
                            in: RoundedRectangle(
                                cornerRadius: 12
                            )
                        )
                    }


                    // MARK: Companion Result

                    if manager.pulseRate != nil &&
                        manager.breathingRate != nil {

                        VStack(spacing: 14) {

                            Text("YOUR COMPANION")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)


                            // MARK: Owl Image

                            Image(companionImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    maxWidth: 220,
                                    maxHeight: 220
                                )
                                .padding(.horizontal, 10)


                            // MARK: Owl Name

                            Text(appState.companion)
                                .font(.title2)
                                .bold()


                            Text(
                                "\(appState.mood) • \(appState.energy)"
                            )
                            .foregroundStyle(.secondary)


                            Divider()
                                .padding(.vertical, 4)


                            // MARK: Vital Assessment

                            Text("YOUR VITALS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)


                            HStack(spacing: 12) {

                                // Pulse

                                VitalStatusCard(
                                    emoji: "❤️",
                                    title: "Pulse Rate",
                                    value: "\(pulseText) BPM",
                                    status: pulseStatus
                                )


                                // Breathing

                                VitalStatusCard(
                                    emoji: "🌬️",
                                    title: "Breathing",
                                    value: "\(breathingText) /min",
                                    status: breathingStatus
                                )
                            }


                            // MARK: Cortex AI

                            cortexAnalysisView


                            Text(
                                "Reference ranges and AI analysis are for informational purposes and are not a medical diagnosis."
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding()
                        .background(
                            .thinMaterial,
                            in: RoundedRectangle(
                                cornerRadius: 20
                            )
                        )
                    }


                    // MARK: Start / Finish Button

                    Button {

                        handleMeasurementButton()

                    } label: {

                        HStack(spacing: 8) {

                            if isLoadingAnalysis {

                                ProgressView()
                                    .tint(.white)

                            } else {

                                Image(
                                    systemName:
                                        manager.isRunning
                                        ? "stop.fill"
                                        : "heart.fill"
                                )
                            }


                            Text(buttonText)
                                .fontWeight(.semibold)
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding()
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .disabled(isLoadingAnalysis)
                }
                .padding()
            }
            .navigationTitle("Vitals")
        }


        // MARK: Receive SmartSpectra Updates

        .task(
            id: manager.metricsUpdateToken
        ) {

            manager.mergeCurrentMetrics()

            saveVitals()
        }
    }


    // MARK: - Button Text

    private var buttonText: String {

        if isLoadingAnalysis {
            return "Analyzing..."
        }

        if manager.isRunning {
            return "Finish Measurement"
        }

        return "Start Measurement"
    }


    // MARK: - Cortex Analysis View

    @ViewBuilder
    private var cortexAnalysisView: some View {

        if isLoadingAnalysis {

            HStack(spacing: 10) {

                ProgressView()


                Text(
                    "Analyzing with Snowflake Cortex..."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .padding(.vertical, 12)

        } else if let analysis = cortexAnalysis {

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                HStack(spacing: 6) {

                    Image(
                        systemName: "sparkles"
                    )
                    .foregroundStyle(.blue)


                    Text(
                        "CORTEX AI ANALYSIS"
                    )
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                }


                Text(analysis)
                    .font(.subheadline)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )


                Divider()


                HStack(spacing: 5) {

                    Image(
                        systemName: "snowflake"
                    )


                    Text(
                        "Powered by Snowflake Cortex AI"
                    )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
            .background(
                Color.blue.opacity(0.06),
                in: RoundedRectangle(
                    cornerRadius: 14
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: 14
                )
                .stroke(
                    Color.blue.opacity(0.15),
                    lineWidth: 1
                )
            }

        } else if let error = cortexError {

            HStack(
                alignment: .top,
                spacing: 8
            ) {

                Image(
                    systemName:
                        "exclamationmark.triangle.fill"
                )


                Text(error)
            }
            .font(.caption)
            .foregroundStyle(.red)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
            .background(
                Color.red.opacity(0.08),
                in: RoundedRectangle(
                    cornerRadius: 12
                )
            )
        }
    }


    // MARK: - Measurement Button

    private func handleMeasurementButton() {

        measurementError = nil

        Task {

            do {

                if manager.isRunning {

                    // Grab final values BEFORE stopping.

                    manager.mergeCurrentMetrics()


                    let finalHeartRate =
                        manager.pulseRate

                    let finalBreathingRate =
                        manager.breathingRate


                    // Save final values.

                    saveVitals()


                    // Stop SmartSpectra.

                    try await manager.stopMeasurement()


                    // Call Snowflake Cortex.

                    if let heartRate = finalHeartRate,
                       let breathingRate = finalBreathingRate {

                        await fetchCortexAnalysis(
                            heartRate: heartRate,
                            breathingRate: breathingRate
                        )

                    } else {

                        await MainActor.run {

                            cortexError =
                                "Heart rate and breathing rate are required for AI analysis."
                        }
                    }

                } else {

                    // Starting a new measurement.

                    await MainActor.run {

                        cortexAnalysis = nil

                        cortexError = nil
                    }


                    try await manager.startMeasurement()
                }

            } catch {

                await MainActor.run {

                    measurementError =
                        error.localizedDescription
                }


                print(
                    "SmartSpectra error:",
                    error
                )
            }
        }
    }


    // MARK: - Snowflake Cortex API

    @MainActor
    private func fetchCortexAnalysis(
        heartRate: Double,
        breathingRate: Double
    ) async {

        isLoadingAnalysis = true

        cortexAnalysis = nil

        cortexError = nil


        defer {

            isLoadingAnalysis = false
        }


        // Deployed Vercel endpoint

        guard let url = URL(
            string:
                "https://test2-five-jet-34.vercel.app/api/cortex"
        ) else {

            cortexError =
                "Invalid Cortex API URL."

            return
        }


        do {

            // MARK: Request

            var request =
                URLRequest(url: url)


            request.httpMethod =
                "POST"


            request.setValue(
                "application/json",
                forHTTPHeaderField:
                    "Content-Type"
            )


            // MARK: JSON Body

            let requestBody: [String: Double] = [

                "heartRate":
                    heartRate,

                "breathingRate":
                    breathingRate
            ]


            request.httpBody =
                try JSONSerialization.data(
                    withJSONObject:
                        requestBody
                )


            print(
                "Sending Cortex request:",
                requestBody
            )


            // MARK: Send

            let (
                data,
                response
            ) = try await URLSession.shared.data(
                for: request
            )


            guard let httpResponse =
                response as? HTTPURLResponse else {

                throw URLError(
                    .badServerResponse
                )
            }


            print(
                "Cortex HTTP status:",
                httpResponse.statusCode
            )


            // Print exact response in Xcode console.

            if let rawResponse =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print(
                    "Cortex raw response:",
                    rawResponse
                )
            }


            // MARK: Validate HTTP

            guard
                (200...299)
                    .contains(
                        httpResponse.statusCode
                    )
            else {

                let serverMessage =
                    String(
                        data: data,
                        encoding: .utf8
                    )
                    ?? "Unknown server error"


                cortexError =
                    "Cortex API error: \(serverMessage)"

                return
            }


            // MARK: Decode

            let result =
                try JSONDecoder().decode(
                    CortexResponse.self,
                    from: data
                )


            guard result.success else {

                cortexError =
                    result.error
                    ?? result.details
                    ?? "Snowflake Cortex analysis failed."

                return
            }


            // IMPORTANT:
            //
            // Your deployed endpoint returns:
            //
            // "summary": "Your heart rate..."
            //
            // so we read SUMMARY here.

            guard
                let summary = result.summary,
                !summary.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            else {

                cortexError =
                    "Snowflake Cortex returned no analysis."

                return
            }


            // MARK: Display Result

            cortexAnalysis =
                summary


            print(
                "Snowflake Cortex analysis:",
                summary
            )

        } catch {

            print(
                "Cortex request error:",
                error
            )


            cortexError =
                "Unable to analyze your vitals: \(error.localizedDescription)"
        }
    }


    // MARK: - Save Vitals

    private func saveVitals() {

        appState.updateVitals(
            heartRate:
                manager.pulseRate,

            breathingRate:
                manager.breathingRate
        )
    }


    // MARK: - Companion Image

    private var companionImageName: String {

        switch appState.companion {

        case "Chill Owl":
            return "chill"

        case "Hype Owl":
            return "hype"

        case "Smiley Owl":
            return "smiley"

        default:
            return "smiley"
        }
    }
}


// MARK: - Vital Status

private enum VitalStatus {

    case low
    case normal
    case high
    case unknown


    var text: String {

        switch self {

        case .low:
            return "LOW"

        case .normal:
            return "NORMAL"

        case .high:
            return "HIGH"

        case .unknown:
            return "--"
        }
    }


    var icon: String {

        switch self {

        case .low:
            return "arrow.down.circle.fill"

        case .normal:
            return "checkmark.circle.fill"

        case .high:
            return "arrow.up.circle.fill"

        case .unknown:
            return "questionmark.circle"
        }
    }


    var color: Color {

        switch self {

        case .low:
            return .orange

        case .normal:
            return .green

        case .high:
            return .red

        case .unknown:
            return .secondary
        }
    }
}


// MARK: - Vital Status Card

private struct VitalStatusCard: View {

    let emoji: String

    let title: String

    let value: String

    let status: VitalStatus


    var body: some View {

        VStack(spacing: 8) {

            Text(emoji)
                .font(.title)


            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)


            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .monospacedDigit()


            HStack(spacing: 4) {

                Image(
                    systemName:
                        status.icon
                )


                Text(status.text)
                    .fontWeight(.bold)
            }
            .font(.caption)
            .foregroundStyle(
                status.color
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(
            status.color.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 14
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: 14
            )
            .stroke(
                status.color.opacity(0.25),
                lineWidth: 1
            )
        }
    }
}


// MARK: - Live Vital Value

private struct VitalValueView: View {

    let emoji: String

    let value: String

    let unit: String


    var body: some View {

        VStack(spacing: 5) {

            Text(emoji)
                .font(.largeTitle)


            Text(value)
                .font(
                    .system(
                        size: 36,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .monospacedDigit()


            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


// MARK: - Preview

#Preview {

    VitalsView()
        .environmentObject(
            WhatTheHootState()
        )
}
