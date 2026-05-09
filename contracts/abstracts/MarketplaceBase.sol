// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "../interfaces/IFrameMarketplace.sol";

abstract contract MarketplaceBase is
    IFrameMarketplace,
    AccessControl,
    Pausable,
    ReentrancyGuard,
    ERC721Holder,
    ERC1155Holder
{
    // =============================================================
    //                             ROLES
    // =============================================================

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    uint96 public constant MAX_MARKETPLACE_FEE_BPS = 1000;

    uint256 internal constant BPS_DENOMINATOR = 10_000;

    // =============================================================
    //                            STORAGE
    // =============================================================

    uint256 public nextListingId;

    uint96 public marketplaceFeeBps;

    address public treasury;

    mapping(uint256 => Listing) public listings;

    // =============================================================
    //                            PUBLICS
    // =============================================================

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControl, ERC1155Holder)
        returns (bool)
    {
        return
            interfaceId == type(IFrameMarketplace).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // =============================================================
    //                           INTERNALS
    // =============================================================

    function _transferNFT(
        address from,
        address to,
        Listing memory listing
    ) internal {
        if (listing.standard == TokenStandard.ERC721) {
            IERC721(listing.nft).safeTransferFrom(from, to, listing.tokenId);
        } else if (listing.standard == TokenStandard.ERC1155) {
            IERC1155(listing.nft).safeTransferFrom(
                from,
                to,
                listing.tokenId,
                listing.amount,
                ""
            );
        } else {
            revert UnsupportedTokenStandard();
        }
    }

    function _sendNative(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");

        if (!success) {
            revert TransferFailed();
        }
    }

    function _getRoyaltyInfo(
        address nft,
        uint256 tokenId,
        uint256 salePrice
    ) internal view returns (address royaltyReceiver, uint256 royaltyAmount) {
        if (IERC165(nft).supportsInterface(type(IERC2981).interfaceId)) {
            return IERC2981(nft).royaltyInfo(tokenId, salePrice);
        }

        return (address(0), 0);
    }
}
