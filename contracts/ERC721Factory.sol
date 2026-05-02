// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./ERC721SingleTokenFrame.sol";
import "./interfaces/IFrameFactory.sol";

contract ERC721Factory is IFrameFactory, AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(address _admin) IFrameFactory() {
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
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
        emit PausedStateChanged(true);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
        emit PausedStateChanged(false);
    }
}
