import SwiftUI
import UIKit

struct SelfieView: View {

    @EnvironmentObject
    private var appState: WhatTheHootState

    @State private var showCamera = false
    @State private var isMinting = false
    @State private var isSharing = false

    @State private var errorMessage: String?
    @State private var mintSuccess = false
    @State private var shareSuccess = false

    // MARK: - Selfie Editor

    // Raw camera image before the owl is permanently added.
    @State private var rawSelfie: UIImage?

    @State private var showSelfieEditor = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    // MARK: - Companion

                    VStack(spacing: 8) {

                        Image(companionImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 140,
                                height: 140
                            )

                        Text(appState.companion)
                            .font(.title2)
                            .bold()

                        Text(
                            "\(appState.mood) • \(appState.energy)"
                        )
                        .foregroundStyle(.secondary)
                    }

                    // MARK: - Final Photo

                    if let selfie = appState.selfie {

                        VStack(spacing: 12) {

                            Image(uiImage: selfie)
                                .resizable()
                                .scaledToFit()
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 20
                                    )
                                )

                            Text(
                                "Your Hoot selfie is ready!"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                    } else {

                        ZStack {

                            RoundedRectangle(
                                cornerRadius: 20
                            )
                            .fill(
                                Color.secondary
                                    .opacity(0.15)
                            )

                            VStack(spacing: 12) {

                                Image(
                                    systemName: "camera.fill"
                                )
                                .font(
                                    .system(size: 50)
                                )

                                Text(
                                    "Take your Hoot Selfie"
                                )
                                .font(.headline)

                                Text(
                                    "\(appState.companion) will join your photo!"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .foregroundStyle(.secondary)
                        }
                        .frame(height: 350)
                    }

                    // MARK: - Camera Button

                    Button {

                        showCamera = true

                    } label: {

                        Label(
                            appState.selfie == nil
                                ? "Take Selfie"
                                : "Retake Selfie",
                            systemImage: "camera.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)

                    // MARK: - Edit Again

                    if appState.selfie != nil,
                       rawSelfie != nil,
                       appState.nftMintAddress == nil {

                        Button {

                            showSelfieEditor = true

                        } label: {

                            Label(
                                "Edit Owl Position",
                                systemImage: "hand.draw.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.bordered)
                    }

                    // MARK: - Mint Button

                    if appState.selfie != nil &&
                        appState.nftMintAddress == nil {

                        Button {

                            mintNFT()

                        } label: {

                            HStack {

                                if isMinting {
                                    ProgressView()
                                }

                                Image(
                                    systemName: "sparkles"
                                )

                                Text(
                                    isMinting
                                        ? "Minting..."
                                        : "Mint WhatTheHoot NFT"
                                )
                                .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isMinting)
                    }

                    // MARK: - Error

                    if let errorMessage {

                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(
                                .center
                            )
                            .padding()
                    }

                    // MARK: - Mint Success

                    if let mint =
                        appState.nftMintAddress {

                        VStack(spacing: 16) {

                            Text("🎉")
                                .font(
                                    .system(size: 50)
                                )

                            Text("NFT Minted!")
                                .font(.title2)
                                .bold()

                            Text(
                                "Your WhatTheHoot NFT has been minted on Solana."
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                            .multilineTextAlignment(
                                .center
                            )

                            Text(mint)
                                .font(.caption)
                                .monospaced()
                                .textSelection(
                                    .enabled
                                )
                                .multilineTextAlignment(
                                    .center
                                )

                            // MARK: Explorer

                            if let explorer =
                                appState
                                    .nftExplorerURL,

                               let url =
                                URL(
                                    string:
                                        explorer
                                ) {

                                Link(
                                    destination: url
                                ) {

                                    Label(
                                        "View on Solana Explorer",
                                        systemImage:
                                            "arrow.up.right.square"
                                    )
                                    .frame(
                                        maxWidth:
                                            .infinity
                                    )
                                    .padding()
                                }
                                .buttonStyle(
                                    .bordered
                                )
                            }

                            Divider()

                            // MARK: Share Explanation

                            if !shareSuccess {

                                VStack(
                                    spacing: 6
                                ) {

                                    Text(
                                        "Share Your Hoot"
                                    )
                                    .font(.headline)

                                    Text(
                                        "Your NFT is private in WhatTheHoot until you choose to share it."
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                                    .multilineTextAlignment(
                                        .center
                                    )
                                }

                                // MARK: Share Button

                                Button {

                                    shareNFT()

                                } label: {

                                    HStack {

                                        if isSharing {
                                            ProgressView()
                                        }

                                        Image(
                                            systemName:
                                                "square.and.arrow.up"
                                        )

                                        Text(
                                            isSharing
                                                ? "Sharing..."
                                                : "Share to WhatTheHoot Gallery"
                                        )
                                        .fontWeight(
                                            .semibold
                                        )
                                    }
                                    .frame(
                                        maxWidth:
                                            .infinity
                                    )
                                    .padding()
                                }
                                .buttonStyle(
                                    .borderedProminent
                                )
                                .disabled(
                                    isSharing
                                )

                            } else {

                                // MARK: Shared Success

                                VStack(
                                    spacing: 10
                                ) {

                                    Image(
                                        systemName:
                                            "checkmark.circle.fill"
                                    )
                                    .font(
                                        .system(
                                            size: 40
                                        )
                                    )
                                    .foregroundStyle(
                                        .green
                                    )

                                    Text(
                                        "Shared to Gallery!"
                                    )
                                    .font(.headline)

                                    Text(
                                        "Your WhatTheHoot NFT is now visible in the public gallery."
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                                    .multilineTextAlignment(
                                        .center
                                    )
                                }
                            }
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
                .padding()
            }
            .navigationTitle("Selfie")
        }

        // MARK: - Camera Sheet

        .sheet(
            isPresented: $showCamera
        ) {

            CameraPicker(
                image: $rawSelfie
            )
        }

        // MARK: - Detect New Camera Photo

        .onChange(of: rawSelfie) { _, newImage in

            guard newImage != nil else {
                return
            }

            // Clear previous finalized image.

            appState.selfie = nil

            // Open editor automatically.

            showSelfieEditor = true
        }

        // MARK: - Editor Sheet

        .fullScreenCover(
            isPresented: $showSelfieEditor
        ) {

            if let rawSelfie {

                SelfieEditorView(
                    selfie: rawSelfie,
                    companionImageName:
                        companionImageName
                ) { finalImage in

                    appState.selfie =
                        finalImage

                    showSelfieEditor =
                        false

                } onCancel: {

                    showSelfieEditor =
                        false
                }

            } else {

                Text("No selfie available")
            }
        }
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

    // MARK: - Mint

    private func mintNFT() {

        guard let image =
            appState.selfie else {
            return
        }

        isMinting = true
        errorMessage = nil
        mintSuccess = false
        shareSuccess = false

        Task {

            do {

                // ---------------------------------
                // 1. Mint NFT on Solana
                // ---------------------------------

                let response =
                    try await NFTService
                        .shared
                        .mintNFT(
                            image: image,

                            recipientWallet:
                                appState
                                    .recipientWallet,

                            petType:
                                appState
                                    .companion,

                            mood:
                                appState
                                    .mood,

                            energy:
                                appState
                                    .energy
                        )

                // ---------------------------------
                // 2. Save NFT privately
                // ---------------------------------

                try await NFTService
                    .shared
                    .saveNFTToGallery(
                        mintResponse:
                            response,

                        heartRate:
                            appState
                                .heartRate,

                        breathingRate:
                            appState
                                .breathingRate
                    )

                // ---------------------------------
                // 3. Update UI
                // ---------------------------------

                await MainActor.run {

                    appState
                        .nftMintAddress =
                        response
                            .nft
                            .mintAddress

                    appState
                        .nftExplorerURL =
                        response
                            .explorer

                    mintSuccess = true
                    isMinting = false
                }

            } catch {

                await MainActor.run {

                    errorMessage =
                        error
                            .localizedDescription

                    isMinting = false
                }
            }
        }
    }

    // MARK: - Share NFT

    private func shareNFT() {

        guard let mintAddress =
            appState
                .nftMintAddress else {
            return
        }

        isSharing = true
        errorMessage = nil

        Task {

            do {

                try await NFTService
                    .shared
                    .shareNFT(
                        mintAddress:
                            mintAddress
                    )

                await MainActor.run {

                    shareSuccess = true
                    isSharing = false
                }

            } catch {

                await MainActor.run {

                    errorMessage =
                        error
                            .localizedDescription

                    isSharing = false
                }
            }
        }
    }
}


// MARK: - Selfie Editor

struct SelfieEditorView: View {

    let selfie: UIImage
    let companionImageName: String

    let onSave: (UIImage) -> Void
    let onCancel: () -> Void

    // MARK: Owl Transform

    @State
    private var owlPosition:
        CGPoint = .zero

    @State
    private var owlScale:
        CGFloat = 1.0

    @State
    private var previousScale:
        CGFloat = 1.0

    // MARK: Editor

    var body: some View {

        NavigationStack {

            GeometryReader { geometry in

                let availableSize =
                    geometry.size

                let imageRect =
                    SelfieEditorGeometry
                        .aspectFitRect(
                            imageSize:
                                selfie.size,

                            inside:
                                availableSize
                        )

                ZStack {

                    Color.black
                        .ignoresSafeArea()

                    // MARK: Selfie

                    Image(uiImage: selfie)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:
                                availableSize.width,

                            height:
                                availableSize.height
                        )

                    // MARK: Movable Owl

                    Image(
                        companionImageName
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            baseOwlWidth(
                                imageRect:
                                    imageRect
                            )
                    )
                    .scaleEffect(
                        owlScale
                    )
                    .position(
                        owlPosition == .zero
                        ? defaultOwlPosition(
                            imageRect:
                                imageRect
                        )
                        : owlPosition
                    )

                    // MARK: Drag

                    .gesture(

                        DragGesture()
                            .onChanged { value in

                                let desired =
                                    value.location

                                owlPosition =
                                    clampPosition(
                                        desired,
                                        imageRect:
                                            imageRect
                                    )
                            }
                    )

                    // MARK: Pinch

                    .simultaneousGesture(

                        MagnificationGesture()

                            .onChanged { value in

                                let newScale =
                                    previousScale
                                    * value

                                owlScale =
                                    min(
                                        max(
                                            newScale,
                                            0.4
                                        ),
                                        3.0
                                    )
                            }

                            .onEnded { _ in

                                previousScale =
                                    owlScale

                                let currentPosition =
                                    owlPosition == .zero
                                    ? defaultOwlPosition(
                                        imageRect:
                                            imageRect
                                    )
                                    : owlPosition

                                owlPosition =
                                    clampPosition(
                                        currentPosition,
                                        imageRect:
                                            imageRect
                                    )
                            }
                    )

                    // MARK: Instructions

                    VStack {

                        VStack(spacing: 5) {

                            Text(
                                "Customize Your Hoot"
                            )
                            .font(.headline)

                            Text(
                                "Drag to move • Pinch to resize"
                            )
                            .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            .black.opacity(0.55),
                            in:
                                Capsule()
                        )

                        Spacer()
                    }
                    .padding(.top, 16)
                    .allowsHitTesting(false)
                }

                .onAppear {

                    if owlPosition == .zero {

                        owlPosition =
                            defaultOwlPosition(
                                imageRect:
                                    imageRect
                            )
                    }
                }

                // Recalculate if device/layout changes.

                .onChange(
                    of: availableSize
                ) { _, _ in

                    owlPosition =
                        defaultOwlPosition(
                            imageRect:
                                imageRect
                        )
                }
            }

            .navigationTitle(
                "Edit Selfie"
            )

            .navigationBarTitleDisplayMode(
                .inline
            )

            .toolbar {

                // MARK: Cancel

                ToolbarItem(
                    placement:
                        .topBarLeading
                ) {

                    Button("Cancel") {

                        onCancel()
                    }
                }

                // MARK: Reset

                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {

                    Button {

                        owlPosition =
                            .zero

                        owlScale =
                            1.0

                        previousScale =
                            1.0

                    } label: {

                        Image(
                            systemName:
                                "arrow.counterclockwise"
                        )
                    }
                }

                // MARK: Save

                ToolbarItem(
                    placement:
                        .bottomBar
                ) {

                    Button {

                        saveFinalPhoto()

                    } label: {

                        Label(
                            "Save Photo",
                            systemImage:
                                "checkmark.circle.fill"
                        )
                        .fontWeight(.bold)
                    }
                }
            }
        }
    }

    // MARK: - Base Owl Size

    private func baseOwlWidth(
        imageRect: CGRect
    ) -> CGFloat {

        imageRect.width * 0.30
    }

    // MARK: - Default Position

    private func defaultOwlPosition(
        imageRect: CGRect
    ) -> CGPoint {

        let owlWidth =
            baseOwlWidth(
                imageRect:
                    imageRect
            )

        let owlImage =
            UIImage(
                named:
                    companionImageName
            )

        let aspectRatio =
            (owlImage?.size.height ?? 1)
            /
            max(
                owlImage?.size.width ?? 1,
                1
            )

        let owlHeight =
            owlWidth
            * aspectRatio

        let padding =
            imageRect.width
            * 0.04

        return CGPoint(

            x:
                imageRect.maxX
                - (
                    owlWidth
                    * owlScale
                    / 2
                )
                - padding,

            y:
                imageRect.maxY
                - (
                    owlHeight
                    * owlScale
                    / 2
                )
                - padding
        )
    }

    // MARK: - Keep Owl Inside Photo

    private func clampPosition(
        _ position: CGPoint,
        imageRect: CGRect
    ) -> CGPoint {

        guard let owlImage =
            UIImage(
                named:
                    companionImageName
            ) else {

            return position
        }

        let width =
            baseOwlWidth(
                imageRect:
                    imageRect
            )
            * owlScale

        let ratio =
            owlImage.size.height
            /
            max(
                owlImage.size.width,
                1
            )

        let height =
            width
            * ratio

        let halfWidth =
            width / 2

        let halfHeight =
            height / 2

        let minimumX =
            imageRect.minX
            + halfWidth

        let maximumX =
            imageRect.maxX
            - halfWidth

        let minimumY =
            imageRect.minY
            + halfHeight

        let maximumY =
            imageRect.maxY
            - halfHeight

        return CGPoint(

            x:
                min(
                    max(
                        position.x,
                        minimumX
                    ),
                    maximumX
                ),

            y:
                min(
                    max(
                        position.y,
                        minimumY
                    ),
                    maximumY
                )
        )
    }

    // MARK: - Save Final Photo

    private func saveFinalPhoto() {

        guard let owl =
            UIImage(
                named:
                    companionImageName
            ) else {

            return
        }

        /*
         We need the dimensions of the actual
         on-screen image in order to translate
         the SwiftUI owl position into pixels
         in the original UIImage.

         SelfieComposer handles that conversion.
        */

        let screen =
            UIScreen.main.bounds.size

        let imageRect =
            SelfieEditorGeometry
                .aspectFitRect(
                    imageSize:
                        selfie.size,

                    inside:
                        screen
                )

        let finalPosition =
            owlPosition == .zero
            ? defaultOwlPosition(
                imageRect:
                    imageRect
            )
            : owlPosition

        let finalImage =
            SelfieComposer
                .addOwl(
                    to:
                        selfie,

                    owl:
                        owl,

                    owlPosition:
                        finalPosition,

                    owlScale:
                        owlScale,

                    displayedImageRect:
                        imageRect
                )

        onSave(
            finalImage
        )
    }
}


// MARK: - Editor Geometry

enum SelfieEditorGeometry {

    static func aspectFitRect(
        imageSize: CGSize,
        inside containerSize: CGSize
    ) -> CGRect {

        guard imageSize.width > 0,
              imageSize.height > 0,
              containerSize.width > 0,
              containerSize.height > 0 else {

            return .zero
        }

        let imageAspect =
            imageSize.width
            /
            imageSize.height

        let containerAspect =
            containerSize.width
            /
            containerSize.height

        var width:
            CGFloat

        var height:
            CGFloat

        if imageAspect >
            containerAspect {

            width =
                containerSize.width

            height =
                width
                / imageAspect

        } else {

            height =
                containerSize.height

            width =
                height
                * imageAspect
        }

        let x =
            (
                containerSize.width
                - width
            ) / 2

        let y =
            (
                containerSize.height
                - height
            ) / 2

        return CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
}


// MARK: - Camera Picker

struct CameraPicker:
    UIViewControllerRepresentable {

    @Binding
    var image: UIImage?

    @Environment(
        \.dismiss
    )
    private var dismiss

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker =
            UIImagePickerController()

        picker.sourceType =
            .camera

        picker.cameraDevice =
            .front

        picker.delegate =
            context.coordinator

        return picker
    }

    func updateUIViewController(
        _ uiViewController:
            UIImagePickerController,
        context: Context
    ) {
    }

    func makeCoordinator()
        -> Coordinator {

        Coordinator(self)
    }

    final class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        let parent:
            CameraPicker

        init(
            _ parent:
                CameraPicker
        ) {

            self.parent =
                parent
        }

        func imagePickerController(
            _ picker:
                UIImagePickerController,

            didFinishPickingMediaWithInfo info:
                [
                    UIImagePickerController
                        .InfoKey: Any
                ]
        ) {

            guard let originalImage =
                info[
                    .originalImage
                ] as? UIImage else {

                parent.dismiss()
                return
            }

            /*
             IMPORTANT:

             Do NOT add the owl here.

             Keep the original camera image so
             the user can position and resize
             the owl in SelfieEditorView.
            */

            parent.image =
                SelfieComposer
                    .normalize(
                        originalImage
                    )

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker:
                UIImagePickerController
        ) {

            parent.dismiss()
        }
    }
}


// MARK: - Selfie Composer

enum SelfieComposer {

    static func addOwl(
        to selfie: UIImage,
        owl: UIImage,
        owlPosition: CGPoint,
        owlScale: CGFloat,
        displayedImageRect: CGRect
    ) -> UIImage {

        let normalizedSelfie =
            normalize(
                selfie
            )

        let selfieSize =
            normalizedSelfie.size

        guard displayedImageRect.width > 0,
              displayedImageRect.height > 0 else {

            return normalizedSelfie
        }

        // MARK: - Convert Preview Coordinates to Image Coordinates

        let relativeX =
            (
                owlPosition.x
                - displayedImageRect.minX
            )
            /
            displayedImageRect.width

        let relativeY =
            (
                owlPosition.y
                - displayedImageRect.minY
            )
            /
            displayedImageRect.height

        let imageCenterX =
            relativeX
            * selfieSize.width

        let imageCenterY =
            relativeY
            * selfieSize.height

        // MARK: - Owl Size

        // Editor starts the owl at 30% of image width.

        let owlWidth =
            selfieSize.width
            * 0.30
            * owlScale

        let owlAspectRatio =
            owl.size.height
            /
            max(
                owl.size.width,
                1
            )

        let owlHeight =
            owlWidth
            * owlAspectRatio

        // CGPoint represents owl center.

        let owlRect =
            CGRect(

                x:
                    imageCenterX
                    - owlWidth / 2,

                y:
                    imageCenterY
                    - owlHeight / 2,

                width:
                    owlWidth,

                height:
                    owlHeight
            )

        // MARK: - Render

        let format =
            UIGraphicsImageRendererFormat()

        format.scale =
            normalizedSelfie.scale

        format.opaque =
            true

        let renderer =
            UIGraphicsImageRenderer(
                size:
                    selfieSize,
                format:
                    format
            )

        return renderer.image { _ in

            normalizedSelfie.draw(
                in:
                    CGRect(
                        origin: .zero,
                        size: selfieSize
                    )
            )

            owl.draw(
                in:
                    owlRect
            )
        }
    }

    // MARK: - Normalize Camera Image

    static func normalize(
        _ image: UIImage
    ) -> UIImage {

        if image.imageOrientation ==
            .up {

            return image
        }

        let format =
            UIGraphicsImageRendererFormat()

        format.scale =
            image.scale

        format.opaque =
            false

        let renderer =
            UIGraphicsImageRenderer(
                size:
                    image.size,
                format:
                    format
            )

        return renderer.image { _ in

            image.draw(
                in:
                    CGRect(
                        origin:
                            .zero,
                        size:
                            image.size
                    )
            )
        }
    }
}


// MARK: - Preview

#Preview {

    SelfieView()
        .environmentObject(
            WhatTheHootState()
        )
}
