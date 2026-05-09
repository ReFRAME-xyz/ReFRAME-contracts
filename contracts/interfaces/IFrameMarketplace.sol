// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFrameMarketplace {
    // =============================================================
    //                            ENUMS
    // =============================================================

    enum TokenStandard {
        ERC721,
        ERC1155
    }

    // =============================================================
    //                           STRUCTS
    // =============================================================

    struct Listing {
        uint256 listingId;
        address nft;
        uint256 tokenId;
        uint256 amount;
        address seller;
        uint256 price;
        bool active;
        bool locked;
        TokenStandard standard;
    }

    // =============================================================
    //                            EVENTS
    // =============================================================

    event Listed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nft,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        TokenStandard standard
    );

    event Delisted(uint256 indexed listingId);

    event Purchased(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 price
    );

    event ListingLocked(uint256 indexed listingId);

    event ListingUnlocked(uint256 indexed listingId);

    event MarketplaceFeeUpdated(uint96 oldFee, uint96 newFee);

    event TreasuryUpdated(address oldTreasury, address newTreasury);

    event EmergencyWithdrawERC20(address token, uint256 amount);

    event EmergencyWithdrawNative(uint256 amount);

    event EmergencyWithdrawERC721(address nft, uint256 tokenId);

    event EmergencyWithdrawERC1155(
        address nft,
        uint256 tokenId,
        uint256 amount
    );

    // =============================================================
    //                            ERRORS
    // =============================================================

    error InvalidAddress();
    error InvalidPrice();
    error InvalidAmount();
    error InvalidMarketplaceFee();
    error ListingNotFound();
    error ListingInactive();
    error ListingLockedError();
    error Unauthorized();
    error InvalidPaymentAmount();
    error TransferFailed();
    error UnsupportedTokenStandard();
    error NFTNotOwned();

    // =============================================================
    //                         MAIN FUNCTIONS
    // =============================================================

    function listERC721(address nft, uint256 tokenId, uint256 price) external;

    function listERC1155(
        address nft,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    ) external;

    function delist(uint256 listingId) external;

    function buy(uint256 listingId) external payable;
}
