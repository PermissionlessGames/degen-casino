// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Preferred Currency Pricing (PCPricing) Library
/// @author Permissionless Games & ChatGpt
/// @notice This library enables dynamic price adjustments based on preferred currency usage.
/// @dev When the anchor currency is used, the price of all other tracked currencies can be decreased.
///      A universal adjustment factor applies to all non-anchor currencies, promoting dynamic pricing models.

library PCPricing {
    using PCPricing for PCPricing.PricingData;

    struct PricingData {
        bytes anchorCurrency; // The anchor (base) currency
        uint256 adjustmentNumerator; // The numerator of the universal adjustment percentage
        uint256 adjustmentDenominator; // The denominator of the universal adjustment percentage
        mapping(bytes => uint256) currencyPrice; // Mapping of currency prices
        bytes[] trackedCurrencies; // List of tracked non-anchor currencies
    }

    /// @notice Set the anchor currency and its initial price
    function setAnchorCurrency(
        PricingData storage self,
        bytes memory currency,
        uint256 price
    ) internal {
        require(price > 0, "Anchor price must be greater than 0");

        self.anchorCurrency = currency;
        self.currencyPrice[currency] = price;
    }

    /// @notice Set the universal adjustment percentage for all non-anchor currencies
    function setAdjustmentFactor(
        PricingData storage self,
        uint256 numerator,
        uint256 denominator
    ) internal {
        require(denominator > 0, "Denominator must be greater than 0");

        self.adjustmentNumerator = numerator;
        self.adjustmentDenominator = denominator;
    }

    /// @notice Set the initial price for a specific currency
    function setCurrencyPrice(
        PricingData storage self,
        bytes memory currency,
        uint256 price
    ) internal {
        require(price > 0, "Price must be greater than 0");
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Cannot set price for anchor currency"
        );

        if (self.currencyPrice[currency] == 0) {
            self.trackedCurrencies.push(currency);
        }

        self.currencyPrice[currency] = price;
    }

    /// @notice Adjust the price dynamically based on usage (same adjustment for all non-anchor currencies)
    function adjustCurrencyPrice(
        PricingData storage self,
        bytes memory currency,
        bool increase
    ) internal {
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Anchor currency cannot be adjusted"
        );
        require(self.currencyPrice[currency] > 0, "Currency price not set");

        uint256 adjustmentAmount = (self.currencyPrice[currency] *
            self.adjustmentNumerator) / self.adjustmentDenominator;
        //set adjustmentAmount to a min of 1
        adjustmentAmount = adjustmentAmount > 0 ? adjustmentAmount : 1;

        if (increase) {
            self.currencyPrice[currency] += adjustmentAmount; // Increase price
        } else {
            // Ensure price can decrease, if price can't decrease do to underflow set value to 1
            self.currencyPrice[currency] = self.currencyPrice[currency] >
                adjustmentAmount
                ? self.currencyPrice[currency] - adjustmentAmount
                : 1;
        }
    }

    /// @notice Reduce the price of all non-anchor currencies when the anchor currency is used
    function reduceAllNonAnchorPrices(PricingData storage self) internal {
        for (uint256 i = 0; i < self.trackedCurrencies.length; i++) {
            bytes memory currency = self.trackedCurrencies[i];
            if (keccak256(currency) != keccak256(self.anchorCurrency)) {
                adjustCurrencyPrice(self, currency, false);
            }
        }
    }

    /// @notice Get the current price of a currency
    function getCurrencyPrice(
        PricingData storage self,
        bytes memory currency
    ) internal view returns (uint256 price) {
        require(self.currencyPrice[currency] > 0, "Currency price not set");
        return self.currencyPrice[currency];
    }

    /// @notice Get all tracked currency prices
    function getAllCurrencyPrices(
        PricingData storage self
    ) internal view returns (bytes[] memory, uint256[] memory) {
        uint256 length = self.trackedCurrencies.length;
        bytes[] memory currencies = new bytes[](length);
        uint256[] memory prices = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            bytes memory currency = self.trackedCurrencies[i];
            currencies[i] = currency;
            prices[i] = self.currencyPrice[currency];
        }

        return (currencies, prices);
    }
}
