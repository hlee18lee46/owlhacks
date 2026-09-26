import { NextRequest, NextResponse } from "next/server";
import axios from "axios";
import FormData from "form-data";
import bs58 from "bs58";

import { createUmi } from "@metaplex-foundation/umi-bundle-defaults";
import {
  generateSigner,
  keypairIdentity,
  percentAmount,
  publicKey,
} from "@metaplex-foundation/umi";

import {
  mplTokenMetadata,
  createNft,
} from "@metaplex-foundation/mpl-token-metadata";

// ============================================================
// WhatTheHoot NFT Minting API
//
// POST /api/mint-nft
//
// Flow:
//
// image
//   ↓
// Pinata / IPFS
//   ↓
// NFT metadata JSON
//   ↓
// Pinata / IPFS
//   ↓
// Metaplex
//   ↓
// Solana Devnet
//   ↓
// NFT sent to recipientWallet
// ============================================================

export async function POST(req: NextRequest) {
  try {
    // ========================================================
    // 1. Read form data
    // ========================================================

    const form = await req.formData();

    const recipientWallet =
      form.get("recipientWallet") as string | null;

    const file =
      form.get("image") as File | null;

    // --------------------------------------------------------
    // WhatTheHoot game traits
    // --------------------------------------------------------

    const petType =
      (form.get("petType") as string | null) ||
      "Smiley Owl";

    const mood =
      (form.get("mood") as string | null) ||
      "Chill";

    const energy =
      (form.get("energy") as string | null) ||
      "Balanced";

    // --------------------------------------------------------
    // NFT information
    // --------------------------------------------------------

    const name =
      (form.get("name") as string | null) ||
      process.env.NFT_NAME ||
      "WhatTheHoot";

    const symbol =
      (form.get("symbol") as string | null) ||
      process.env.NFT_SYMBOL ||
      "HOOT";

    const description =
      (form.get("description") as string | null) ||
      process.env.NFT_DESCRIPTION ||
      "Your personalized WhatTheHoot companion.";

    // ========================================================
    // 2. Validate required data
    // ========================================================

    if (!recipientWallet) {
      return NextResponse.json(
        {
          error: "recipientWallet is required",
        },
        {
          status: 400,
        }
      );
    }

    if (!file) {
      return NextResponse.json(
        {
          error: "image file is required",
        },
        {
          status: 400,
        }
      );
    }

    // ========================================================
    // 3. Validate Solana wallet
    // ========================================================

    let owner;

    try {
      owner = publicKey(recipientWallet);
    } catch {
      return NextResponse.json(
        {
          error: "Invalid Solana recipient wallet",
        },
        {
          status: 400,
        }
      );
    }

    // ========================================================
    // 4. Validate image
    // ========================================================

    const allowedTypes = [
      "image/png",
      "image/jpeg",
      "image/webp",
    ];

    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json(
        {
          error:
            "Only PNG, JPEG, and WebP images are supported",
        },
        {
          status: 400,
        }
      );
    }

    // 10 MB maximum
    const maxFileSize =
      10 * 1024 * 1024;

    if (file.size > maxFileSize) {
      return NextResponse.json(
        {
          error:
            "Image must be smaller than 10 MB",
        },
        {
          status: 400,
        }
      );
    }

    // ========================================================
    // 5. Environment variables
    // ========================================================

    const pinataJwt =
      process.env.PINATA_JWT;

    const pinataGateway =
      process.env.PINATA_GATEWAY;

    const solanaPrivateKey =
      process.env.SOLANA_PRIVATE_KEY_BASE58;

    const rpcUrl =
      process.env.SOLANA_RPC_URL ||
      "https://api.devnet.solana.com";

    if (!pinataJwt) {
      return NextResponse.json(
        {
          error: "PINATA_JWT is missing",
        },
        {
          status: 500,
        }
      );
    }

    if (!pinataGateway) {
      return NextResponse.json(
        {
          error: "PINATA_GATEWAY is missing",
        },
        {
          status: 500,
        }
      );
    }

    if (!solanaPrivateKey) {
      return NextResponse.json(
        {
          error:
            "SOLANA_PRIVATE_KEY_BASE58 is missing",
        },
        {
          status: 500,
        }
      );
    }

    // Remove trailing slash
    //
    // Example:
    // https://olive-advanced-catshark-729.mypinata.cloud/ipfs

    const normalizedGateway =
      pinataGateway.replace(/\/+$/, "");

    // ========================================================
    // 6. Upload image to Pinata
    // ========================================================

    console.log(
      "[WhatTheHoot] Uploading image..."
    );

    const bytes =
      await file.arrayBuffer();

    const buffer =
      Buffer.from(bytes);

    const uploadForm =
      new FormData();

    uploadForm.append(
      "file",
      buffer,
      {
        filename:
          file.name ||
          `whatthehoot-${Date.now()}.png`,

        contentType:
          file.type ||
          "image/png",
      }
    );

    const pinataFileRes =
      await axios.post(
        "https://api.pinata.cloud/pinning/pinFileToIPFS",
        uploadForm,
        {
          maxBodyLength: Infinity,

          headers: {
            ...uploadForm.getHeaders(),

            Authorization:
              `Bearer ${pinataJwt}`,
          },
        }
      );

    const imageCID =
      pinataFileRes.data.IpfsHash;

    // ========================================================
    // 7. Create image URLs
    // ========================================================

    // Portable IPFS URI
    const imageIpfsUri =
      `ipfs://${imageCID}`;

    // HTTPS URL
    //
    // We use THIS inside NFT metadata because
    // explorers/wallets can fetch it directly.

    const imageUrl =
      `${normalizedGateway}/${imageCID}`;

    console.log(
      "[WhatTheHoot] Image uploaded:"
    );

    console.log(imageUrl);

    // ========================================================
    // 8. Create NFT metadata
    // ========================================================

    /*
      IMPORTANT:

      We intentionally don't put raw Presage
      heart rate / breathing rate in permanent
      NFT metadata.

      Instead:

      Presage
          ↓
      HR + breathing
          ↓
      WhatTheHoot algorithm
          ↓
      Companion / Mood / Energy
          ↓
      NFT traits
    */

    const metadata = {
      name,

      symbol,

      description,

      seller_fee_basis_points: 0,

      // IMPORTANT:
      // Use HTTPS instead of ipfs:// here
      // for maximum wallet/explorer compatibility.

      image: imageUrl,

      external_url:
        process.env.NEXT_PUBLIC_APP_URL ||
        undefined,

      attributes: [
        {
          trait_type: "Companion",
          value: petType,
        },
        {
          trait_type: "Mood",
          value: mood,
        },
        {
          trait_type: "Energy",
          value: energy,
        },
        {
          trait_type: "Project",
          value: "WhatTheHoot",
        },
      ],

      properties: {
        files: [
          {
            // Also use HTTPS here
            uri: imageUrl,

            type:
              file.type ||
              "image/png",
          },
        ],

        category: "image",
      },
    };

    console.log(
      "[WhatTheHoot] Metadata:"
    );

    console.log(
      JSON.stringify(
        metadata,
        null,
        2
      )
    );

    // ========================================================
    // 9. Upload metadata JSON to Pinata
    // ========================================================

    console.log(
      "[WhatTheHoot] Uploading metadata..."
    );

    const pinataJsonRes =
      await axios.post(
        "https://api.pinata.cloud/pinning/pinJSONToIPFS",
        metadata,
        {
          headers: {
            "Content-Type":
              "application/json",

            Authorization:
              `Bearer ${pinataJwt}`,
          },
        }
      );

    const metadataCID =
      pinataJsonRes.data.IpfsHash;

    // IPFS representation
    const metadataIpfsUri =
      `ipfs://${metadataCID}`;

    // HTTPS representation
    const metadataUrl =
      `${normalizedGateway}/${metadataCID}`;

    console.log(
      "[WhatTheHoot] Metadata uploaded:"
    );

    console.log(metadataUrl);

    // ========================================================
    // 10. Decode Solana private key
    // ========================================================

    let secretKey:
      Uint8Array;

    try {
      secretKey =
        bs58.decode(
          solanaPrivateKey
        );
    } catch {
      return NextResponse.json(
        {
          error:
            "SOLANA_PRIVATE_KEY_BASE58 is invalid",
        },
        {
          status: 500,
        }
      );
    }

    // ========================================================
    // 11. Initialize UMI
    // ========================================================

    const umi =
      createUmi(rpcUrl)
        .use(
          mplTokenMetadata()
        );

    const umiKeypair =
      umi.eddsa.createKeypairFromSecretKey(
        secretKey
      );

    // Server wallet becomes transaction payer
    umi.use(
      keypairIdentity(
        umiKeypair
      )
    );

    // ========================================================
    // 12. Generate NFT mint
    // ========================================================

    const mint =
      generateSigner(umi);

    console.log(
      "[WhatTheHoot] Mint address:"
    );

    console.log(
      mint.publicKey.toString()
    );

    // ========================================================
    // 13. Mint NFT
    // ========================================================

    console.log(
      "[WhatTheHoot] Minting NFT..."
    );

    const result =
      await createNft(
        umi,
        {
          mint,

          name,

          symbol,

          // ==================================================
          // IMPORTANT CHANGE
          //
          // Store the HTTPS metadata URL on-chain instead of:
          //
          // ipfs://CID
          //
          // This allows Solana Explorer/wallets to directly
          // retrieve our JSON.
          // ==================================================

          uri: metadataUrl,

          sellerFeeBasisPoints:
            percentAmount(0),

          // Send NFT to recipient
          tokenOwner:
            owner,

          // Can update metadata later
          isMutable:
            true,
        }
      ).sendAndConfirm(umi);

    // ========================================================
    // 14. Prepare result
    // ========================================================

    const mintAddress =
      mint.publicKey.toString();

    const signature =
      bs58.encode(
        result.signature
      );

    console.log(
      "[WhatTheHoot] NFT successfully minted!"
    );

    console.log(
      "[WhatTheHoot] Mint:",
      mintAddress
    );

    console.log(
      "[WhatTheHoot] Transaction:",
      signature
    );

    // ========================================================
    // 15. Return response
    // ========================================================

    return NextResponse.json({
      ok: true,

      project:
        "WhatTheHoot",

      recipientWallet,

      nft: {
        mintAddress,

        name,

        symbol,

        petType,

        mood,

        energy,
      },

      transaction: {
        signature,
      },

      image: {
        cid:
          imageCID,

        ipfsUri:
          imageIpfsUri,

        url:
          imageUrl,
      },

      metadata: {
        cid:
          metadataCID,

        ipfsUri:
          metadataIpfsUri,

        // This is the URI stored in the NFT
        url:
          metadataUrl,
      },

      explorer:
        `https://explorer.solana.com/address/${mintAddress}?cluster=devnet`,
    });
  } catch (err: any) {
    // ========================================================
    // Error handling
    // ========================================================

    console.error(
      "[WhatTheHoot] NFT mint error:",
      err
    );

    if (
      axios.isAxiosError(err)
    ) {
      console.error(
        "[WhatTheHoot] HTTP response:",
        err.response?.data
      );
    }

    return NextResponse.json(
      {
        ok: false,

        error:
          err?.message ||
          "WhatTheHoot NFT mint failed",

        details:
          err?.response?.data ||
          null,
      },
      {
        status: 500,
      }
    );
  }
}