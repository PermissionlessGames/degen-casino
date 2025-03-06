// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMultipleCurrencyToken {
    struct CreatePricingDataParams {
        address currency;
        uint256 price;
        bool is1155;
        uint256 tokenId;
    }

    function tokens(
        uint256 index
    ) external view returns (CreatePricingDataParams memory);

    function encodeCurrency(
        address currency,
        uint256 tokenId,
        bool is1155
    ) external pure returns (bytes memory);

    function getMintPrice(
        bytes memory currency
    ) external view returns (uint256);

    function getRedeemPrice(
        bytes memory currency
    ) external view returns (uint256);

    function deposit(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external payable returns (uint256 mintAmount);

    function withdraw(
        address currency,
        uint256 tokenId,
        uint256 amountIn
    ) external returns (uint256 amountOut);

    function estimateDepositAmount(
        address[] memory currencies,
        uint256[] memory tokenIds,
        uint256[] memory deposits
    ) external view returns (uint256 amount);

    function getTokens()
        external
        view
        returns (
            address[] memory currencies,
            uint256[] memory tokenIds,
            bool[] memory is1155
        );

    function doesCurrencyExist(
        address currency,
        uint256 tokenId,
        bool is1155
    ) external view returns (bool);

    event NewPricingDataAdded(CreatePricingDataParams pricingData);
}
