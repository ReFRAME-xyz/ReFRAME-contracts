// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IERC1155Frame.sol";

contract ERC1155SingleTokenFrame is
    ERC1155Burnable,
    ERC2981,
    IERC1155Frame,
    AccessControl
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 1;
    uint256 public constant TOKEN_ID = 1;

    address public creator;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // max supply of each token ID
    mapping(uint256 => uint256) public editionSizes;

    // total supply of each token ID
    mapping(uint256 => uint256) public editionCounts;

    constructor(
        string memory name_,
        string memory symbol_,
        uint96 _royaltyPercentage,
        uint256 _editionSize
    ) ERC1155("") {
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

        _name = name_;
        _symbol = symbol_;
        creator = tx.origin;

        // Set royalty using ERC2981 with basis points (1 bp = 0.01%)
        if (_royaltyPercentage > 0) {
            _setDefaultRoyalty(creator, _royaltyPercentage);
        }

        editionSizes[TOKEN_ID] = _editionSize;
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        if (editionCounts[tokenId] >= editionSizes[tokenId]) {
            revert EditionSizeExceeded(tokenId, editionSizes[tokenId]);
        }
        _mint(to, tokenId, amount, data);
        editionCounts[tokenId] += amount;
    }

    function mintBatch(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (editionCounts[tokenIds[i]] >= editionSizes[tokenIds[i]]) {
                revert EditionSizeExceeded(
                    tokenIds[i],
                    editionSizes[tokenIds[i]]
                );
            }
            editionCounts[tokenIds[i]] += amounts[i];
        }
        _mintBatch(to, tokenIds, amounts, data);
    }

    function burn(address account, uint256 id, uint256 amount) public override {
        super.burn(account, id, amount);
        editionCounts[id] -= amount;
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public override {
        super.burnBatch(account, ids, amounts);
        for (uint256 i = 0; i < ids.length; i++) {
            editionCounts[ids[i]] -= amounts[i];
        }
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://test.xyz/api/metadata/",
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
    )
        public
        view
        virtual
        override(ERC1155, ERC2981, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
