// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IFrame.sol";

contract ERC1155SingleTokenFrame is ERC1155, IFrame {
    uint256 public constant MAX_SUPPLY = 1;
    uint256 public constant TOKEN_ID = 1;

    uint256 public royaltyPercentage = 5; // 5% royalty
    address public minter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage
    ) ERC1155("") IFrame() {
        if (_royaltyPercentage < 5 || _royaltyPercentage > 100) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }

        _name = _name;
        _symbol = _symbol;

        royaltyPercentage = _royaltyPercentage;
        minter = tx.origin;

        _mint(tx.origin, TOKEN_ID, 1, "");
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

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}
