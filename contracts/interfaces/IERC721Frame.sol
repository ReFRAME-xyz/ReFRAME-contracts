// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IFrame.sol";

interface IERC721Frame is IFrame {
    error TokenAlreadyMinted(uint256 tokenId);
    error MaxSupplyReached();

    function mint(address to, uint256 tokenId) external;
}
