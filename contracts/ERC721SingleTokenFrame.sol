// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IFrame.sol";

contract ERC721SingleTokenFrame is ERC721Burnable, IFrame, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 1;
    uint256 public royaltyPercentage;
    address public creator;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage
    ) ERC721(_name, _symbol) IFrame() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        if (
            _royaltyPercentage != 0 &&
            (_royaltyPercentage < 5 || _royaltyPercentage > 100)
        ) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }
        royaltyPercentage = _royaltyPercentage;
        creator = tx.origin;
        _mint(tx.origin, 1);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://reframehub.xyz/api/metadata/";
    }
}
