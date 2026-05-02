// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./interfaces/IFrame.sol";

contract ERC721SingleTokenFrame is ERC721, IFrame {
    uint256 public constant MAX_SUPPLY = 1;
    uint256 public royaltyPercentage = 5; // 5% royalty
    address public minter;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage
    ) ERC721(_name, _symbol) IFrame() {
        if (_royaltyPercentage < 5 || _royaltyPercentage > 100) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }
        royaltyPercentage = _royaltyPercentage;
        minter = tx.origin;
        _mint(tx.origin, 1);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://reframehub.xyz/api/metadata/";
    }
}
