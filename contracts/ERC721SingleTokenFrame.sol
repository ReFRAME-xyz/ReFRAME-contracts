// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IERC721Frame.sol";

contract ERC721SingleTokenFrame is
    ERC721Burnable,
    ERC2981,
    IERC721Frame,
    AccessControl
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 1;
    uint256 public totalSupply;
    address public creator;

    constructor(
        string memory _name,
        string memory _symbol,
        uint96 _royaltyPercentage
    ) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        // Validate royalty in basis points: 1 bp = 0.01%, so 10000 bp = 100%
        // Allowed range: 500 bp (5%) to 10000 bp (100%)
        if (
            _royaltyPercentage != 0 &&
            (_royaltyPercentage < 500 || _royaltyPercentage > 10000)
        ) {
            revert InvalidRoyaltyPercentage(_royaltyPercentage);
        }

        creator = tx.origin;

        // Set royalty using ERC2981 with basis points (1 bp = 0.01%)
        if (_royaltyPercentage > 0) {
            _setDefaultRoyalty(creator, _royaltyPercentage);
        }
    }

    function mint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        if (_ownerOf(tokenId) != address(0)) {
            revert TokenAlreadyMinted(tokenId);
        }
        if (totalSupply >= MAX_SUPPLY) {
            revert MaxSupplyReached();
        }
        _safeMint(to, tokenId);
        totalSupply++;
    }

    function burn(uint256 tokenId) public override {
        super.burn(tokenId);
        totalSupply--;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC2981, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://test.xyz/api/metadata/";
    }
}
