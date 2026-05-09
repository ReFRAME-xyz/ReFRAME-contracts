// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC1155FrameFactory {
    /// @notice Emitted when a new NFT is created
    event NFTDropped(
        address indexed nftAddress,
        address indexed creator,
        uint256 editionSize
    );

    /// @notice Emitted when a new NFT is minted
    event NFTMinted(
        address indexed nftAddress,
        address indexed to,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice Emitted when factory is paused or unpaused
    event PausedStateChanged(bool isPaused);

    /// @notice Function to create a new NFT
    function dropNFT(
        string memory _name,
        string memory _symbol,
        uint96 _royaltyPercentage, // in basis points (1 bp = 0.01%)
        uint256 _editionSize
    ) external;
}
