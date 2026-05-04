// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IFrame.sol";

contract ERC1155SingleTokenFrame is ERC1155Burnable, IFrame, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
