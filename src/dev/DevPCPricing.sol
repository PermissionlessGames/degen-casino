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
    }

    /// @notice Manually adjust a currency price
    function adjustCurrencyPrice(
        bytes memory currency,
        bool increase
    ) external {
        pricingData.adjustCurrencyPrice(currency, increase);
    }

    /// @notice Reduce all non-anchor currency prices when the anchor is used
    /// @dev WARNING: This function may hit gas limits with large currency arrays
    function useAnchorCurrency(bool increase) external {
        pricingData.adjustAllNonAnchorPrices(increase);
    }

    /// @notice Process a batch of non-anchor currency price adjustments
    /// @param increase Whether to increase or decrease prices
    /// @param batchSize Maximum number of currencies to process
    /// @return processedCount Number of currencies processed
    function adjustNonAnchorPricesBatch(
        bool increase,
        uint256 batchSize
    ) external returns (uint256) {
        return pricingData.adjustNonAnchorPricesBatch(increase, batchSize);
    }

    /// @notice Get the current state of batch processing
    /// @return lastProcessedIndex The index where processing will resume
    /// @return totalCurrencies Total number of tracked currencies
    function getBatchProcessingState()
        external
        view
        returns (uint256 lastProcessedIndex, uint256 totalCurrencies)
    {
        return pricingData.getBatchProcessingState();
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

    function getAdjustmentFactor() external view returns (uint256, uint256) {
        return (
            pricingData.adjustmentNumerator,
            pricingData.adjustmentDenominator
        );
    }

    /// @notice Get the anchor currency
    function getAnchorCurrency() external view returns (bytes memory) {
        return pricingData.anchorCurrency;
    }

    /// @notice Get all tracked non-anchor currencies
    function getTrackedCurrencies() external view returns (bytes[] memory) {
        return pricingData.trackedCurrencies;
    }

    /// @notice Get the index of a specific currency
    function getCurrencyIndex(
        bytes memory currency
    ) external view returns (uint256) {
        return pricingData.currencyIndex[currency];
    }

    /// @notice Check if a currency exists in the system
    function currencyExists(
        bytes memory currency
    ) external view returns (bool) {
        return pricingData.currencyExists(currency);
    }

    /// @notice Remove a currency from the system
    function removeCurrency(bytes memory currency) external {
        pricingData.removeCurrency(currency);
    }

    /// @notice Set the batch size for processing large arrays of currencies
    /// @param newBatchSize The maximum number of currencies to process in a single batch
    function setBatchSize(uint256 newBatchSize) external {
        pricingData.setBatchSize(newBatchSize);
    }

    /// @notice Get the current batch size setting
    function getBatchSize() external view returns (uint256) {
        return pricingData.batchSize;
    }
}
