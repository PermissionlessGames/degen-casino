// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/PCPricing.sol";

/// @title DevPCPricing Debugging Contract
/// @author  Permissionless Games & ChatGPT
/// @notice This contract is for debugging and testing the PCPricing library on test networks.
/// @dev Allows setting, adjusting, and retrieving currency prices in a simulated test environment.

contract DevPCPricing {
    using PCPricing for PCPricing.PricingData;

    PCPricing.PricingData private pricingData;
    event PriceUpdated(bytes indexed currency, uint256 newPrice);
    event AllPricesReduced();

    /// @notice Constructor initializes the anchor currency and default adjustment factor
    /// @param anchorCurrency The anchor currency (e.g., ETH)
    /// @param anchorPrice The starting price of the anchor currency
    /// @param adjNumerator The numerator of the adjustment percentage
    /// @param adjDenominator The denominator of the adjustment percentage
    constructor(
        bytes memory anchorCurrency,
        uint256 anchorPrice,
        uint256 adjNumerator,
        uint256 adjDenominator
    ) {
        pricingData.setAnchorCurrency(anchorCurrency, anchorPrice);
        pricingData.setAdjustmentFactor(adjNumerator, adjDenominator);
    }

    /// @notice Set a new currency price
    function setCurrencyPrice(bytes memory currency, uint256 price) external {
        pricingData.setCurrencyPrice(currency, price);
        emit PriceUpdated(currency, price);
    }

    /// @notice Manually adjust a currency price
    function adjustCurrencyPrice(
        bytes memory currency,
        bool increase
    ) external {
        pricingData.adjustCurrencyPrice(currency, increase);
        emit PriceUpdated(currency, pricingData.getCurrencyPrice(currency));
    }

    /// @notice Reduce all non-anchor currency prices when the anchor is used
    function useAnchorCurrency() external {
        pricingData.reduceAllNonAnchorPrices();
        emit AllPricesReduced();
    }

    /// @notice Get a specific currency price
    function getCurrencyPrice(
        bytes memory currency
    ) external view returns (uint256) {
        return pricingData.getCurrencyPrice(currency);
    }

    /// @notice Retrieve all stored currency prices
    function getAllCurrencyPrices()
        external
        view
        returns (bytes[] memory, uint256[] memory)
    {
        return pricingData.getAllCurrencyPrices();
    }
}
