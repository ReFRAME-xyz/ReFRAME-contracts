// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./ERC721SingleTokenFrame.sol";
import "./interfaces/IERC721FrameFactory.sol";

contract ERC721SingleTokenFactory is
    IERC721FrameFactory,
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
        uint256 _royaltyPercentage
    ) external whenNotPaused {
        ERC721SingleTokenFrame newNFT = new ERC721SingleTokenFrame(
            _name,
            _symbol,
            _royaltyPercentage
        );

        emit NFTDropped(address(newNFT), msg.sender);

        newNFT.supportsInterface(0x80ac58cd);

        newNFT.mint(msg.sender, 1);

        emit NFTMinted(address(newNFT), msg.sender, 1);

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
        ERC721SingleTokenFrame(newNFTAddress).grantRole(
            ERC721SingleTokenFrame(newNFTAddress).DEFAULT_ADMIN_ROLE(),
            msg.sender
        );
        ERC721SingleTokenFrame(newNFTAddress).grantRole(
            ERC721SingleTokenFrame(newNFTAddress).ADMIN_ROLE(),
            msg.sender
        );
        ERC721SingleTokenFrame(newNFTAddress).grantRole(
            ERC721SingleTokenFrame(newNFTAddress).MINTER_ROLE(),
            msg.sender
        );
        ERC721SingleTokenFrame(newNFTAddress).renounceRole(
            ERC721SingleTokenFrame(newNFTAddress).DEFAULT_ADMIN_ROLE(),
            address(this)
        );
        ERC721SingleTokenFrame(newNFTAddress).renounceRole(
            ERC721SingleTokenFrame(newNFTAddress).ADMIN_ROLE(),
            address(this)
        );
        ERC721SingleTokenFrame(newNFTAddress).renounceRole(
            ERC721SingleTokenFrame(newNFTAddress).MINTER_ROLE(),
            address(this)
        );
    }
}
