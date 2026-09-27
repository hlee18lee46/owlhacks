import SwiftUI

struct GalleryView: View {

    @State private var nfts: [GalleryNFT] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let endpoint =
        "https://test2-five-jet-34.vercel.app/api/nft-gallery"

    private let columns = [
        GridItem(
            .flexible(),
            spacing: 16
        ),
        GridItem(
            .flexible(),
            spacing: 16
        )
    ]

    var body: some View {

        NavigationStack {

            Group {

                if isLoading && nfts.isEmpty {

                    loadingView

                } else if let errorMessage,
                          nfts.isEmpty {

                    errorView(errorMessage)

                } else if nfts.isEmpty {

                    emptyView

                } else {

                    galleryGrid
                }
            }
            .navigationTitle("Hoot Gallery")
            .refreshable {
                await loadGallery()
            }
            .task {
                await loadGallery()
            }
        }
    }


    // MARK: - Gallery Grid

    private var galleryGrid: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("WhatTheHoot Community")
                        .font(.headline)

                    Text(
                        "\(nfts.count) shared Hoot\(nfts.count == 1 ? "" : "s")"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }


                LazyVGrid(
                    columns: columns,
                    spacing: 16
                ) {

                    ForEach(nfts) { nft in

                        GalleryNFTCard(
                            nft: nft
                        )
                    }
                }
            }
            .padding()
        }
    }


    // MARK: - Loading

    private var loadingView: some View {

        VStack(spacing: 16) {

            ProgressView()
                .controlSize(.large)

            Text("Loading the Hoots...")
                .foregroundStyle(.secondary)
        }
    }


    // MARK: - Empty

    private var emptyView: some View {

        VStack(spacing: 16) {

            Text("🦉")
                .font(.system(size: 70))

            Text("No Hoots Yet")
                .font(.title2)
                .bold()

            Text(
                "Be the first to share your WhatTheHoot NFT!"
            )
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button {

                Task {
                    await loadGallery()
                }

            } label: {

                Label(
                    "Refresh",
                    systemImage: "arrow.clockwise"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }


    // MARK: - Error

    private func errorView(
        _ message: String
    ) -> some View {

        VStack(spacing: 16) {

            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.system(size: 40))

            Text("Could Not Load Gallery")
                .font(.headline)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {

                Task {
                    await loadGallery()
                }

            } label: {

                Label(
                    "Try Again",
                    systemImage: "arrow.clockwise"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }


    // MARK: - Fetch Gallery

    @MainActor
    private func loadGallery() async {

        guard let url =
            URL(string: endpoint) else {

            errorMessage =
                "Invalid gallery URL."

            return
        }

        isLoading = true
        errorMessage = nil

        do {

            var request =
                URLRequest(url: url)

            request.httpMethod = "GET"

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Accept"
            )

            request.timeoutInterval = 30

            let (data, response) =
                try await URLSession
                    .shared
                    .data(for: request)

            guard let httpResponse =
                response as? HTTPURLResponse else {

                throw GalleryError
                    .invalidResponse
            }

            print(
                "🖼 Gallery status:",
                httpResponse.statusCode
            )

            if let responseText =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print(
                    "🖼 Gallery response:",
                    responseText
                )
            }

            guard (200...299)
                .contains(
                    httpResponse.statusCode
                ) else {

                let message =
                    String(
                        data: data,
                        encoding: .utf8
                    )
                    ?? "Unknown server error"

                throw GalleryError
                    .serverError(message)
            }


            let result =
                try JSONDecoder()
                    .decode(
                        GalleryResponse.self,
                        from: data
                    )

            nfts = result.nfts
            isLoading = false

        } catch {

            print(
                "❌ Gallery error:",
                error
            )

            errorMessage =
                error.localizedDescription

            isLoading = false
        }
    }
}


// MARK: - NFT Card

private struct GalleryNFTCard: View {

    let nft: GalleryNFT

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            // MARK: - NFT Image

            nftImage


            // MARK: - Name

            Text(
                nft.name ??
                "WhatTheHoot"
            )
            .font(.headline)
            .lineLimit(1)


            // MARK: - Companion

            HStack(spacing: 5) {

                Text("🦉")

                Text(
                    nft.petType ??
                    "Hoot Companion"
                )
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            }


            // MARK: - Mood + Energy

            if nft.mood != nil ||
                nft.energy != nil {

                Text(traitText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }


            // MARK: - Vitals

            if nft.pulseRate != nil ||
                nft.breathingRate != nil {

                Divider()

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    if let pulse =
                        nft.pulseRate {

                        Label(
                            "\(Int(pulse.rounded())) BPM",
                            systemImage:
                                "heart.fill"
                        )
                        .font(.caption2)
                    }

                    if let breathing =
                        nft.breathingRate {

                        Label(
                            "\(Int(breathing.rounded())) breaths/min",
                            systemImage:
                                "wind"
                        )
                        .font(.caption2)
                    }
                }
            }


            Spacer(minLength: 0)


            // MARK: - Solana Explorer Button

            if let url = URL(
                string:
                    "https://explorer.solana.com/address/\(nft.mintAddress)?cluster=devnet"
            ) {

                Link(destination: url) {

                    HStack(spacing: 8) {

                        Image(systemName: "link")

                        Text("View on Explorer")
                            .fontWeight(.semibold)

                        Spacer()

                        Image(
                            systemName:
                                "arrow.up.right.square"
                        )
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(10)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .background(
            .thinMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 18
                )
        )
    }


    // MARK: - NFT Image

    private var nftImage: some View {

        Group {

            if let explorer =
                nft.explorerUrl,

               let explorerURL =
                URL(string: explorer) {

                Link(
                    destination:
                        explorerURL
                ) {

                    imageContent
                }
                .buttonStyle(.plain)

            } else {

                imageContent
            }
        }
    }


    // MARK: - Image Content

    private var imageContent: some View {

        AsyncImage(
            url: URL(
                string:
                    nft.imageUrl ?? ""
            )
        ) { phase in

            switch phase {

            case .empty:

                ZStack {

                    Rectangle()
                        .fill(
                            Color.secondary
                                .opacity(0.12)
                        )

                    ProgressView()
                }


            case .success(
                let image
            ):

                image
                    .resizable()
                    .scaledToFill()


            case .failure:

                ZStack {

                    Rectangle()
                        .fill(
                            Color.secondary
                                .opacity(0.12)
                        )

                    VStack(
                        spacing: 8
                    ) {

                        Text("🦉")
                            .font(
                                .system(
                                    size: 40
                                )
                            )

                        Text(
                            "Image unavailable"
                        )
                        .font(.caption2)
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }


            @unknown default:

                EmptyView()
            }
        }
        .frame(height: 170)
        .frame(
            maxWidth: .infinity
        )
        .clipped()
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }


    // MARK: - Traits

    private var traitText: String {

        [
            nft.mood,
            nft.energy
        ]
        .compactMap { $0 }
        .joined(
            separator: " • "
        )
    }
}


// MARK: - API Response

private struct GalleryResponse:
    Decodable {

    let success: Bool
    let count: Int
    let nfts: [GalleryNFT]
}


// MARK: - NFT Model

private struct GalleryNFT:
    Decodable,
    Identifiable {

    let mintAddress: String
    let ownerWallet: String

    let name: String?
    let symbol: String?
    let description: String?

    let imageUrl: String?
    let metadataUri: String?

    let petType: String?
    let mood: String?
    let energy: String?

    let pulseRate: Double?
    let breathingRate: Double?

    let transactionSignature:
        String?

    let network: String?

    let isShared: Bool?

    let explorerUrl: String?
    let transactionUrl: String?


    var id: String {
        mintAddress
    }


    enum CodingKeys:
        String,
        CodingKey {

        case mintAddress =
            "mint_address"

        case ownerWallet =
            "owner_wallet"

        case name
        case symbol
        case description

        case imageUrl =
            "image_url"

        case metadataUri =
            "metadata_uri"

        case petType =
            "pet_type"

        case mood
        case energy

        case pulseRate =
            "pulse_rate"

        case breathingRate =
            "breathing_rate"

        case transactionSignature =
            "transaction_signature"

        case network

        case isShared =
            "is_shared"

        case explorerUrl =
            "explorer_url"

        case transactionUrl =
            "transaction_url"
    }
}


// MARK: - Errors

private enum GalleryError:
    LocalizedError {

    case invalidResponse
    case serverError(String)

    var errorDescription:
        String? {

        switch self {

        case .invalidResponse:

            return
                "Invalid response from gallery server."

        case .serverError(
            let message
        ):

            return
                "Gallery server error: \(message)"
        }
    }
}


#Preview {

    GalleryView()
}
