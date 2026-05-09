// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./abstracts/MarketplaceBase.sol";

contract ReframeMarketplace is MarketplaceBase {
    // =============================================================
    //                         CONSTRUCTOR
    // =============================================================

    constructor(address admin, address treasuryAddress, uint96 feeBps) {
        if (admin == address(0)) {
            revert InvalidAddress();
        }

        if (treasuryAddress == address(0)) {
            revert InvalidAddress();
        }

        if (feeBps > MAX_MARKETPLACE_FEE_BPS) {
            revert InvalidMarketplaceFee();
        }

        treasury = treasuryAddress;
        marketplaceFeeBps = feeBps;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
    }

    // =============================================================
    //                         LIST ERC721
    // =============================================================

    function listERC721(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external override whenNotPaused nonReentrant {
        if (price == 0) {
            revert InvalidPrice();
        }

        IERC721 erc721 = IERC721(nft);

        if (erc721.ownerOf(tokenId) != msg.sender) {
            revert NFTNotOwned();
        }

        uint256 listingId = nextListingId++;

        listings[listingId] = Listing({
            listingId: listingId,
            nft: nft,
            tokenId: tokenId,
            amount: 1,
            seller: msg.sender,
            price: price,
            active: true,
            locked: false,
            standard: TokenStandard.ERC721
        });

        erc721.safeTransferFrom(msg.sender, address(this), tokenId);

        if (erc721.ownerOf(tokenId) != address(this)) {
            revert TransferFailed();
        }

        emit Listed(
            listingId,
            msg.sender,
            nft,
            tokenId,
            1,
            price,
            TokenStandard.ERC721
        );
    }

    // =============================================================
    //                        LIST ERC1155
    // =============================================================

    function listERC1155(
        address nft,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    ) external override whenNotPaused nonReentrant {
        if (price == 0) {
            revert InvalidPrice();
        }

        if (amount == 0) {
            revert InvalidAmount();
        }

        IERC1155 erc1155 = IERC1155(nft);

        if (erc1155.balanceOf(msg.sender, tokenId) < amount) {
            revert NFTNotOwned();
        }

        uint256 listingId = nextListingId++;

        listings[listingId] = Listing({
            listingId: listingId,
            nft: nft,
            tokenId: tokenId,
            amount: amount,
            seller: msg.sender,
            price: price,
            active: true,
            locked: false,
            standard: TokenStandard.ERC1155
        });

        uint256 preBalance = erc1155.balanceOf(address(this), tokenId);

        erc1155.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            ""
        );

        uint256 postBalance = erc1155.balanceOf(address(this), tokenId);

        if (postBalance - preBalance != amount) {
            revert TransferFailed();
        }

        emit Listed(
            listingId,
            msg.sender,
            nft,
            tokenId,
            amount,
            price,
            TokenStandard.ERC1155
        );
    }

    // =============================================================
    //                           DELIST
    // =============================================================

    function delist(
        uint256 listingId
    ) external override whenNotPaused nonReentrant {
        Listing storage listing = listings[listingId];

        if (!listing.active) {
            revert ListingInactive();
        }

        if (listing.locked) {
            revert ListingLockedError();
        }

        if (
            msg.sender != listing.seller && !hasRole(OPERATOR_ROLE, msg.sender)
        ) {
            revert Unauthorized();
        }

        listing.active = false;

        _transferNFT(address(this), listing.seller, listing);

        emit Delisted(listingId);
    }

    // =============================================================
    //                             BUY
    // =============================================================

    function buy(
        uint256 listingId
    ) external payable override whenNotPaused nonReentrant {
        Listing storage listing = listings[listingId];

        if (!listing.active) {
            revert ListingInactive();
        }

        if (listing.locked) {
            revert ListingLockedError();
        }

        if (msg.value != listing.price) {
            revert InvalidPaymentAmount();
        }

        listing.active = false;

        (address royaltyReceiver, uint256 royaltyAmount) = _getRoyaltyInfo(
            listing.nft,
            listing.tokenId,
            listing.price
        );

        uint256 marketplaceFee = (listing.price * marketplaceFeeBps) /
            BPS_DENOMINATOR;

        uint256 sellerAmount = listing.price - royaltyAmount - marketplaceFee;

        // royalty
        if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
            _sendNative(royaltyReceiver, royaltyAmount);
        }

        // marketplace fee
        if (marketplaceFee > 0) {
            _sendNative(treasury, marketplaceFee);
        }

        // seller payment
        _sendNative(listing.seller, sellerAmount);

        // transfer nft
        _transferNFT(address(this), msg.sender, listing);

        emit Purchased(listingId, msg.sender, listing.price);
    }

    // =============================================================
    //                     LOCK / UNLOCK
    // =============================================================

    function lockListing(uint256 listingId) external onlyRole(OPERATOR_ROLE) {
        Listing storage listing = listings[listingId];

        if (!listing.active) {
            revert ListingInactive();
        }

        listing.locked = true;

        emit ListingLocked(listingId);
    }

    function unlockListing(uint256 listingId) external onlyRole(OPERATOR_ROLE) {
        Listing storage listing = listings[listingId];

        if (!listing.active) {
            revert ListingInactive();
        }

        listing.locked = false;

        emit ListingUnlocked(listingId);
    }

    // =============================================================
    //                       ADMIN ACTIONS
    // =============================================================

    function setMarketplaceFee(uint96 newFee) external onlyRole(ADMIN_ROLE) {
        if (newFee > MAX_MARKETPLACE_FEE_BPS) {
            revert InvalidMarketplaceFee();
        }

        uint96 oldFee = marketplaceFeeBps;

        marketplaceFeeBps = newFee;

        emit MarketplaceFeeUpdated(oldFee, newFee);
    }

    function setTreasury(address newTreasury) external onlyRole(ADMIN_ROLE) {
        if (newTreasury == address(0)) {
            revert InvalidAddress();
        }

        address oldTreasury = treasury;

        treasury = newTreasury;

        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // =============================================================
    //                    EMERGENCY WITHDRAW
    // =============================================================

    function emergencyWithdrawERC20(
        address token,
        uint256 amount
    ) external onlyRole(ADMIN_ROLE) {
        IERC20(token).transfer(msg.sender, amount);

        emit EmergencyWithdrawERC20(token, amount);
    }

    function emergencyWithdrawNative(
        uint256 amount
    ) external onlyRole(ADMIN_ROLE) {
        _sendNative(msg.sender, amount);

        emit EmergencyWithdrawNative(amount);
    }

    function emergencyWithdrawERC721(
        address nft,
        uint256 tokenId,
        address to
    ) external onlyRole(ADMIN_ROLE) {
        IERC721(nft).safeTransferFrom(address(this), to, tokenId);

        emit EmergencyWithdrawERC721(nft, tokenId);
    }

    function emergencyWithdrawERC1155(
        address nft,
        uint256 tokenId,
        uint256 amount,
        address to
    ) external onlyRole(ADMIN_ROLE) {
        IERC1155(nft).safeTransferFrom(address(this), to, tokenId, amount, "");

        emit EmergencyWithdrawERC1155(nft, tokenId, amount);
    }

    receive() external payable {}
}
