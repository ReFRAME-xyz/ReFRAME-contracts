// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IFrame.sol";

contract ERC1155Frame is ERC1155, IFrame {
    uint256 public constant MAX_SUPPLY = 1;
    uint256 public constant TOKEN_ID = 1;
    uint256 public royaltyPercentage = 5; // 5% royalty

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage
    ) ERC1155("") IFrame() {
        if (_royaltyPercentage < 5 || _royaltyPercentage > 100) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }
        royaltyPercentage = _royaltyPercentage;
        _mint(msg.sender, TOKEN_ID, 1, "");
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://reframehub.xyz/api/metadata/",
                    Strings.toString(tokenId)
                )
            );
    }
}
