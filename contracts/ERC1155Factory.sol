// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "./ERC1155SingleTokenFrame.sol";
import "./interfaces/IERC1155FrameFactory.sol";

contract ERC1155Factory is IERC1155FrameFactory, AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(address _admin) IERC1155FrameFactory() {
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
            _royaltyPercentage
        );
        emit NFTDropped(address(newNFT), msg.sender, _editionSize);
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
