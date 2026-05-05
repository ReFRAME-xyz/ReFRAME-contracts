// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IFrame.sol";

interface IERC1155Frame is IFrame {
    error EditionSizeExceeded(uint256 tokenId, uint256 editionSize);

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}
