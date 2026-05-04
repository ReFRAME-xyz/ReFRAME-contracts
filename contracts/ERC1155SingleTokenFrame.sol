// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IFrame.sol";

contract ERC1155SingleTokenFrame is ERC1155Burnable, IFrame {
    uint256 public constant MAX_SUPPLY = 1;
    uint256 public constant TOKEN_ID = 1;

    uint256 public royaltyPercentage;
    address public creator;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _royaltyPercentage
    ) ERC1155("") IFrame() {
        if (
            _royaltyPercentage != 0 &&
            (_royaltyPercentage < 5 || _royaltyPercentage > 100)
        ) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }

        _name = name_;
        _symbol = symbol_;

        royaltyPercentage = _royaltyPercentage;
        creator = tx.origin;

        _mint(tx.origin, TOKEN_ID, 1, "");
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
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
