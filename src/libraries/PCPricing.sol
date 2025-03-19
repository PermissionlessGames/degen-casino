// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Preferred Currency Pricing (PCPricing) Library
/// @author Permissionless Games & ChatGpt
/// @notice This library enables dynamic price adjustments based on preferred currency usage.
/// @dev When the anchor currency is used, the price of all other tracked currencies can be decreased.
///      A universal adjustment factor applies to all non-anchor currencies, promoting dynamic pricing models.

library PCPricing {
    using PCPricing for PCPricing.PricingData;
    /// @notice Emitted when a new anchor currency is set
    /// @param currency The currency that was set as the anchor
    /// @param price The price of the anchor currency
    event AnchorCurrencySet(bytes indexed currency, uint256 price);

    /// @notice Emitted when the adjustment factor is updated
    /// @param numerator The numerator of the adjustment factor
    /// @param denominator The denominator of the adjustment factor
    event AdjustmentFactorSet(uint256 numerator, uint256 denominator);

    /// @notice Emitted when a new currency price is set
    /// @param currency The currency that was set
    /// @param price The price of the currency
    event CurrencyPriceSet(bytes indexed currency, uint256 price);

    /// @notice Emitted when a currency price is adjusted
    /// @param currency The currency that was adjusted
    /// @param newPrice The new price of the currency
    /// @param increased Whether the price was increased or decreased
    event CurrencyPriceAdjusted(
        bytes indexed currency,
        uint256 newPrice,
        bool increased
    );

    /// @notice Emitted when a currency is removed
    /// @param currency The currency that was removed
    event CurrencyRemoved(bytes indexed currency);

    /// @notice Emitted when all non-anchor prices are reduced
    event NonAnchorPricesReduced();

    /// @notice Emitted when a batch of non-anchor prices are adjusted
    event NonAnchorPricesAdjustedBatch(
        uint256 processedCount,
        uint256 nextIndex
    );

    /// @notice Struct for pricing data
    struct PricingData {
        bytes anchorCurrency; // The anchor (base) currency
        uint256 adjustmentNumerator; // The numerator of the universal adjustment percentage
        uint256 adjustmentDenominator; // The denominator of the universal adjustment percentage
        mapping(bytes => uint256) currencyPrice; // Mapping of currency prices
        mapping(bytes => uint256) currencyIndex; // Mapping of currency index
        bytes[] trackedCurrencies; // List of tracked non-anchor currencies
        uint256 lastProcessedIndex; // Index tracking for batch processing
        uint256 batchSize; // Maximum number of currencies to process in a single batch
    }

    /// @notice Set the anchor currency and its initial price
    /// @param currency The currency to set as the anchor
    /// @param price The initial price of the anchor currency
    function setAnchorCurrency(
        PricingData storage self,
        bytes memory currency,
        uint256 price
    ) internal {
        require(price > 0, "Anchor price must be greater than 0");

        self.anchorCurrency = currency;
        self.currencyPrice[currency] = price;

        emit AnchorCurrencySet(currency, price);
    }

    /// @notice Set the universal adjustment percentage for all non-anchor currencies
    /// @param numerator The numerator of the adjustment factor
    /// @param denominator The denominator of the adjustment factor
    function setAdjustmentFactor(
        PricingData storage self,
        uint256 numerator,
        uint256 denominator
    ) internal {
        require(denominator > 1, "Denominator must be greater than 0");
        require(numerator > 0, "Numerator must be greater than 0");
        self.adjustmentNumerator = numerator;
        self.adjustmentDenominator = denominator;

        emit AdjustmentFactorSet(numerator, denominator);
    }

    /// @notice Set the initial price for a specific currency
    /// @param currency The currency to set the price for
    /// @param price The price to set for the currency
    function setCurrencyPrice(
        PricingData storage self,
        bytes memory currency,
        uint256 price
    ) internal {
        require(price > 0, "Price must be greater than 0");
        require(
            keccak256(currency) != keccak256(bytes("")),
            "Currency cannot be empty"
        );
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Cannot set price for anchor currency"
        );

        if (self.currencyPrice[currency] == 0) {
            self.trackedCurrencies.push(currency);
            self.currencyIndex[currency] = self.trackedCurrencies.length - 1;
        }

        self.currencyPrice[currency] = price;

        emit CurrencyPriceSet(currency, price);
    }

    /// @notice Adjust the price dynamically based on usage (same adjustment for all non-anchor currencies)
    /// @param increase Whether to increase or decrease the price
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

        emit CurrencyPriceAdjusted(
            currency,
            self.currencyPrice[currency],
            increase
        );
    }

    /// @notice adjust the price of a batch of non-anchor currencies
    /// @param increase Whether to increase or decrease the price
    /// @param batchSize Maximum number of currencies to process in this transaction
    /// @return (processedCount, hasMore) Number of currencies processed and whether there are more to process
    function adjustNonAnchorPricesBatch(
        PricingData storage self,
        bool increase,
        uint256 batchSize
    ) internal returns (uint256) {
        uint256 length = self.trackedCurrencies.length;
        if (length == 0) return (0);

        uint256 startIndex = self.lastProcessedIndex % length;

        for (uint256 i = 0; i < batchSize; i++) {
            uint256 currentIndex = (startIndex + i) % length;
            bytes memory currency = self.trackedCurrencies[currentIndex];

            if (keccak256(currency) != keccak256(self.anchorCurrency)) {
                adjustCurrencyPrice(self, currency, increase);
            }
        }

        // Update the last processed index, ensuring it wraps around
        self.lastProcessedIndex = (startIndex + batchSize) % length;

        emit NonAnchorPricesAdjustedBatch(batchSize, self.lastProcessedIndex);

        return batchSize;
    }

    /// @notice Set the batch size for processing large arrays of currencies
    /// @param newBatchSize The new batch size
    function setBatchSize(
        PricingData storage self,
        uint256 newBatchSize
    ) internal {
        require(newBatchSize > 0, "Batch size must be greater than 0");
        self.batchSize = newBatchSize;
    }

    /// @notice Legacy function that adjusts all prices in one transaction
    /// @param increase Whether to increase or decrease the price
    /// @dev If trackedCurrencies length exceeds batchSize, it will use batch processing
    function adjustAllNonAnchorPrices(
        PricingData storage self,
        bool increase
    ) internal {
        uint256 length = self.trackedCurrencies.length;

        // If batchSize is not set or array is smaller than batch size, process all at once
        if (self.batchSize == 0 || length <= self.batchSize) {
            for (uint256 i = 0; i < length; i++) {
                bytes memory currency = self.trackedCurrencies[i];
                if (keccak256(currency) != keccak256(self.anchorCurrency)) {
                    adjustCurrencyPrice(self, currency, increase);
                }
            }
            emit NonAnchorPricesReduced();
        } else {
            adjustNonAnchorPricesBatch(self, increase, self.batchSize);
        }
    }

    /// @notice Get the current batch processing state
    /// @return lastProcessedIndex The last processed index
    /// @return totalCurrencies The total number of currencies
    function getBatchProcessingState(
        PricingData storage self
    )
        internal
        view
        returns (uint256 lastProcessedIndex, uint256 totalCurrencies)
    {
        return (self.lastProcessedIndex, self.trackedCurrencies.length);
    }

    /// @notice Get the current price of a currency
    /// @param currency The currency to get the price of
    /// @return price The price of the currency
    function getCurrencyPrice(
        PricingData storage self,
        bytes memory currency
    ) internal view returns (uint256 price) {
        require(self.currencyPrice[currency] > 0, "Currency price not set");
        return self.currencyPrice[currency];
    }

    /// @notice Get all tracked currency prices
    /// @return currencies The list of tracked currencies
    /// @return prices The list of prices for the tracked currencies
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

    /// @notice Check if a currency exists
    /// @param currency The currency to check
    /// @return exists Whether the currency exists
    function currencyExists(
        PricingData storage self,
        bytes memory currency
    ) internal view returns (bool) {
        bool exists = self.currencyPrice[currency] > 0;
        return exists;
    }

    /// @notice Remove a currency from the pricing data
    /// @param currency The currency to remove
    function removeCurrency(
        PricingData storage self,
        bytes memory currency
    ) internal {
        require(self.currencyPrice[currency] > 0, "Currency not found");
        require(
            keccak256(currency) != keccak256(bytes("")),
            "Currency cannot be empty"
        );
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Cannot remove anchor currency"
        );
        uint256 index = self.currencyIndex[currency];
        if (index < self.trackedCurrencies.length - 1) {
            self.trackedCurrencies[index] = self.trackedCurrencies[
                self.trackedCurrencies.length - 1
            ];
            self.currencyIndex[self.trackedCurrencies[index]] = index;
        }
        self.trackedCurrencies.pop();
        delete self.currencyIndex[currency];
        delete self.currencyPrice[currency];

        emit CurrencyRemoved(currency);
    }
}
