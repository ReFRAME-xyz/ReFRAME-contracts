// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721FrameFactory {
    /// @notice Emitted when a new NFT is created
    event NFTDropped(address indexed nftAddress, address indexed creator);

    /// @notice Emitted when factory is paused or unpaused
    event PausedStateChanged(bool isPaused);

    /// @notice Function to create a new NFT
    function dropNFT(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage
    ) external;
}
