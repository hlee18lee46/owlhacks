import Foundation
import UIKit

final class NFTService {

    static let shared = NFTService()

    private init() {}

    // MARK: - Endpoints

    // Solana NFT minting
    private let mintEndpoint =
        "https://owlhacks.vercel.app/api/mint-nft"

    // Save NFT record privately
    private let galleryEndpoint =
        "https://test2-five-jet-34.vercel.app/api/nft-gallery"

    // User explicitly chooses to share
    private let galleryShareEndpoint =
        "https://test2-five-jet-34.vercel.app/api/nft-gallery/share"


    // MARK: - 1. Mint NFT

    func mintNFT(
        image: UIImage,
        recipientWallet: String,
        petType: String,
        mood: String,
        energy: String
    ) async throws -> MintNFTResponse {

        guard let url = URL(string: mintEndpoint) else {
            throw NFTServiceError.invalidURL
        }

        guard let imageData = image.jpegData(
            compressionQuality: 0.85
        ) else {
            throw NFTServiceError.imageConversionFailed
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.timeoutInterval = 120

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        var body = Data()

        appendTextField(
            name: "recipientWallet",
            value: recipientWallet,
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "petType",
            value: petType,
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "mood",
            value: mood,
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "energy",
            value: energy,
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "name",
            value: "WhatTheHoot",
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "symbol",
            value: "HOOT",
            boundary: boundary,
            to: &body
        )

        appendTextField(
            name: "description",
            value: "My personalized WhatTheHoot companion",
            boundary: boundary,
            to: &body
        )

        // MARK: Image

        body.appendString("--\(boundary)\r\n")

        body.appendString(
            "Content-Disposition: form-data; name=\"image\"; filename=\"whatthehoot.jpg\"\r\n"
        )

        body.appendString(
            "Content-Type: image/jpeg\r\n"
        )

        body.appendString("\r\n")

        body.append(imageData)

        body.appendString("\r\n")

        // Close multipart body

        body.appendString(
            "--\(boundary)--\r\n"
        )

        request.httpBody = body

        print("🚀 Mint URL:", url.absoluteString)
        print("📦 Body size:", body.count)

        let (data, response) =
            try await URLSession.shared.data(for: request)

        guard let httpResponse =
            response as? HTTPURLResponse else {

            throw NFTServiceError.invalidResponse
        }

        print(
            "🪙 Mint status:",
            httpResponse.statusCode
        )

        if let text = String(
            data: data,
            encoding: .utf8
        ) {
            print("🪙 Mint response:", text)
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let message =
                String(
                    data: data,
                    encoding: .utf8
                )
                ?? "Unknown mint server error"

            throw NFTServiceError.serverError(
                message
            )
        }

        do {

            return try JSONDecoder().decode(
                MintNFTResponse.self,
                from: data
            )

        } catch {

            print(
                "❌ Mint decoding error:",
                error
            )

            throw NFTServiceError.decodingFailed
        }
    }


    // MARK: - 2. Save NFT Privately

    //
    // This does NOT share the NFT publicly.
    //
    // POST:
    // https://test2-five-jet-34.vercel.app/api/nft-gallery
    //

    func saveNFTToGallery(
        mintResponse: MintNFTResponse,
        heartRate: Double?,
        breathingRate: Double?
    ) async throws {

        guard let url =
            URL(string: galleryEndpoint) else {

            throw NFTServiceError.invalidURL
        }

        var payload: [String: Any] = [

            "mintAddress":
                mintResponse.nft.mintAddress,

            "ownerWallet":
                mintResponse.recipientWallet,

            "name":
                mintResponse.nft.name,

            "symbol":
                mintResponse.nft.symbol,

            "description":
                "My personalized WhatTheHoot companion",

            "imageUrl":
                mintResponse.image.url,

            "metadataUri":
                mintResponse.metadata.url,

            "petType":
                mintResponse.nft.petType,

            "mood":
                mintResponse.nft.mood,

            "energy":
                mintResponse.nft.energy,

            "transactionSignature":
                mintResponse.transaction.signature,

            "network":
                "devnet"
        ]

        if let heartRate {
            payload["pulseRate"] = heartRate
        }

        if let breathingRate {
            payload["breathingRate"] =
                breathingRate
        }

        let jsonData =
            try JSONSerialization.data(
                withJSONObject: payload
            )

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.timeoutInterval = 30

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        request.httpBody = jsonData

        print(
            "💾 Saving NFT privately:",
            mintResponse.nft.mintAddress
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse else {

            throw NFTServiceError.invalidResponse
        }

        if let text = String(
            data: data,
            encoding: .utf8
        ) {
            print(
                "💾 Gallery save response:",
                text
            )
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let message =
                String(
                    data: data,
                    encoding: .utf8
                )
                ?? "Unknown gallery save error"

            throw NFTServiceError.serverError(
                message
            )
        }

        print("✅ NFT saved privately")
    }


    // MARK: - 3. Share NFT

    //
    // ONLY call this when user presses:
    //
    // "Share to WhatTheHoot Gallery"
    //

    func shareNFT(
        mintAddress: String
    ) async throws {

        guard let url =
            URL(string: galleryShareEndpoint) else {

            throw NFTServiceError.invalidURL
        }

        let payload: [String: Any] = [
            "mintAddress": mintAddress
        ]

        let jsonData =
            try JSONSerialization.data(
                withJSONObject: payload
            )

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.timeoutInterval = 30

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        request.httpBody = jsonData

        print(
            "🌎 Sharing NFT:",
            mintAddress
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse else {

            throw NFTServiceError.invalidResponse
        }

        if let text = String(
            data: data,
            encoding: .utf8
        ) {
            print(
                "🌎 Share response:",
                text
            )
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let message =
                String(
                    data: data,
                    encoding: .utf8
                )
                ?? "Unknown gallery share error"

            throw NFTServiceError.serverError(
                message
            )
        }

        print(
            "✅ Shared to WhatTheHoot Gallery"
        )
    }


    // MARK: - Multipart Helper

    private func appendTextField(
        name: String,
        value: String,
        boundary: String,
        to body: inout Data
    ) {

        body.appendString(
            "--\(boundary)\r\n"
        )

        body.appendString(
            "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        )

        body.appendString("\r\n")

        body.appendString(value)

        body.appendString("\r\n")
    }
}


// MARK: - Errors

enum NFTServiceError: LocalizedError {

    case invalidURL

    case imageConversionFailed

    case invalidResponse

    case serverError(String)

    case decodingFailed

    var errorDescription: String? {

        switch self {

        case .invalidURL:

            return "Invalid API URL."

        case .imageConversionFailed:

            return "Could not convert selfie to JPEG."

        case .invalidResponse:

            return "Invalid response from server."

        case .serverError(let message):

            return "Server error: \(message)"

        case .decodingFailed:

            return "Could not decode server response."
        }
    }
}


// MARK: - Data Helper

private extension Data {

    mutating func appendString(
        _ string: String
    ) {

        guard let data =
            string.data(using: .utf8) else {
            return
        }

        append(data)
    }
}
