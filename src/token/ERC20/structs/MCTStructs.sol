// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct MCTTokens {
    address currency;
    uint256 tokenId;
    bool is1155;
}

struct CreatePricingDataParams {
    address currency;
    uint256 price;
    uint256 decimalCount; // 0 for no decimals, 1 for 1 decimal, 2 for 2 decimals, etc. 18 for 18 decimals
    bool is1155;
    uint256 tokenId;
}
