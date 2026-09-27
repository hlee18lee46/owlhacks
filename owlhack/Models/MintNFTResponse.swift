import Foundation

struct MintNFTResponse: Codable {

    let ok: Bool

    let project: String

    let recipientWallet: String

    let nft: NFTInfo

    let transaction: TransactionInfo

    let image: IPFSInfo

    let metadata: IPFSInfo

    let explorer: String
}

// MARK: - NFT

struct NFTInfo: Codable {

    let mintAddress: String

    let name: String

    let symbol: String

    let petType: String

    let mood: String

    let energy: String
}

// MARK: - Transaction

struct TransactionInfo: Codable {

    let signature: String
}

// MARK: - IPFS

struct IPFSInfo: Codable {

    let cid: String

    let ipfsUri: String

    let url: String
}
