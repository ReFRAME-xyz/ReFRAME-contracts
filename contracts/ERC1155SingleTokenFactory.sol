// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./ERC1155SingleTokenFrame.sol";
import "./interfaces/IERC1155FrameFactory.sol";

contract ERC1155SingleTokenFactory is
    IERC1155FrameFactory,
    AccessControl,
    Pausable
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function dropNFT(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyPercentage,
        uint256 _editionSize
    ) external whenNotPaused {
        ERC1155SingleTokenFrame newNFT = new ERC1155SingleTokenFrame(
            _name,
            _symbol,
            _royaltyPercentage,
            _editionSize
        );

        emit NFTDropped(address(newNFT), msg.sender, _editionSize);

        newNFT.mint(msg.sender, newNFT.TOKEN_ID(), _editionSize, "");

        emit NFTMinted(
            address(newNFT),
            msg.sender,
            newNFT.TOKEN_ID(),
            _editionSize
        );

        _setupRoles(address(newNFT));
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
        emit PausedStateChanged(true);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
        emit PausedStateChanged(false);
    }

    function _setupRoles(address newNFTAddress) internal {
        ERC1155SingleTokenFrame(newNFTAddress).grantRole(
            ERC1155SingleTokenFrame(newNFTAddress).DEFAULT_ADMIN_ROLE(),
            msg.sender
        );
        ERC1155SingleTokenFrame(newNFTAddress).grantRole(
            ERC1155SingleTokenFrame(newNFTAddress).ADMIN_ROLE(),
            msg.sender
        );
        ERC1155SingleTokenFrame(newNFTAddress).grantRole(
            ERC1155SingleTokenFrame(newNFTAddress).MINTER_ROLE(),
            msg.sender
        );
        ERC1155SingleTokenFrame(newNFTAddress).renounceRole(
            ERC1155SingleTokenFrame(newNFTAddress).DEFAULT_ADMIN_ROLE(),
            address(this)
        );
        ERC1155SingleTokenFrame(newNFTAddress).renounceRole(
            ERC1155SingleTokenFrame(newNFTAddress).ADMIN_ROLE(),
            address(this)
        );
        ERC1155SingleTokenFrame(newNFTAddress).renounceRole(
            ERC1155SingleTokenFrame(newNFTAddress).MINTER_ROLE(),
            address(this)
        );
    }
}
