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
        mapping(bytes => uint256) adjustmentNumerator; // The numerator of the universal adjustment percentage
        mapping(bytes => uint256) adjustmentDenominator; // The denominator of the universal adjustment percentage
        mapping(bytes => uint256) currencyPrice; // Mapping of currency prices
        mapping(bytes => uint256) currencyIndex; // Mapping of currency index
        uint256 numberOfCurrencies; // Number of currencies
        mapping(uint256 => bytes) currencyIndexToCurrency; // Mapping of currency index to currency
        uint256 nextIndexToProcss; // Index tracking for batch processing
        uint256 batchSize; // Maximum number of currencies to process in a single batch
    }

    /// @notice Set the anchor currency and its initial price
    /// @param currency The currency to set as the anchor
    /// @param price The initial price of the anchor currency
    /// @dev This function is used to set the anchor currency and its initial price can only be called once
    function setAnchorCurrency(
        PricingData storage self,
        bytes memory currency,
        uint256 price
    ) internal {
        require(price > 0, "Anchor price must be greater than 0");

        self.anchorCurrency = currency;
        self.currencyPrice[currency] = price;
        //set the index of the anchor currency is 0
        self.numberOfCurrencies++;
        self.currencyIndexToCurrency[0] = currency;
        self.currencyIndex[currency] = 0;

        emit AnchorCurrencySet(currency, price);
    }

    /// @notice Update the universal adjustment percentage for a specific currency
    /// @param numerator The numerator of the adjustment factor
    /// @param denominator The denominator of the adjustment factor
    function setAdjustmentFactor(
        PricingData storage self,
        bytes memory currency,
        uint256 numerator,
        uint256 denominator
    ) internal {
        require(denominator > 1, "Denominator must be greater than 1");
        require(numerator > 0, "Numerator must be greater than 0");
        require(
            keccak256(currency) != keccak256(bytes("")),
            "Currency cannot be empty"
        );
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Cannot set adjustment factor for anchor currency"
        );
        require(
            self.currencyIndex[currency] != 0,
            "Cannot set adjustment factor for anchor currency"
        );
        self.adjustmentNumerator[currency] = numerator;
        self.adjustmentDenominator[currency] = denominator;

        emit AdjustmentFactorSet(numerator, denominator);
    }

    function addCurrency(
        PricingData storage self,
        bytes memory currency,
        uint256 price,
        uint256 numerator,
        uint256 denominator
    ) internal {
        require(
            keccak256(currency) != keccak256(bytes("")),
            "Currency cannot be empty"
        );
        require(
            keccak256(self.anchorCurrency) != keccak256(currency),
            "Cannot add anchor currency"
        );
        require(self.currencyIndex[currency] == 0, "Currency already exists");

        if (self.currencyPrice[currency] == 0) {
            //set the index of the new currency
            self.currencyIndexToCurrency[self.numberOfCurrencies] = currency;
            self.currencyIndex[currency] = self.numberOfCurrencies;
            self.numberOfCurrencies++;
        }

        setCurrencyPrice(self, currency, price);
        setAdjustmentFactor(self, currency, numerator, denominator);
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
        require(self.currencyIndex[currency] != 0, "Currency not found");
        self.currencyPrice[currency] = price;

        emit CurrencyPriceSet(currency, price);
    }

    /// @notice Adjust the price dynamically based on usage (same adjustment for all non-anchor currencies)
    /// @param increase Whether to increase or decrease the price
    /// @dev This function will not adjust the price of the anchor currency
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
            self.adjustmentNumerator[currency]) /
            self.adjustmentDenominator[currency];
        //set adjustmentAmount to a min of 1
        adjustmentAmount = adjustmentAmount > 0 ? adjustmentAmount : 1;

        if (increase) {
            self.currencyPrice[currency] += adjustmentAmount; // Increase price
        } else {
            // Ensure price can decrease, if price can't decrease do to underflow set value to min 1
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

    /// @notice adjust the price of non-anchor currencies based on batch size
    /// @param increase Whether to increase or decrease the price
    /// @param batchSize Maximum number of currencies to process in this transaction
    /// @return uint256 Number of currencies processed in this update
    /// @dev This function will not adjust the price of the anchor currency
    function adjustNonAnchorPricesBatch(
        PricingData storage self,
        bool increase,
        uint256 batchSize
    ) internal returns (uint256) {
        if (self.numberOfCurrencies == 0) return (0);

        // Get the start index for the batch processing ensuring it wraps around
        uint256 startIndex = self.nextIndexToProcss % self.numberOfCurrencies;

        for (uint256 i = 0; i < batchSize; i++) {
            uint256 currentIndex = (startIndex + i) % self.numberOfCurrencies;
            bytes memory currency = self.currencyIndexToCurrency[currentIndex];

            if (keccak256(currency) != keccak256(self.anchorCurrency)) {
                adjustCurrencyPrice(self, currency, increase);
            }
        }

        // Update the last processed index, ensuring it wraps around
        self.nextIndexToProcss =
            (startIndex + batchSize) %
            self.numberOfCurrencies;

        emit NonAnchorPricesAdjustedBatch(batchSize, self.nextIndexToProcss);

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
    /// @dev If the number of currencies exceed the batchsize, it will instead only process the batchsize
    /// @dev This function will not adjust the price of the anchor currency
    function adjustAllNonAnchorPrices(
        PricingData storage self,
        bool increase
    ) internal {
        // If batchSize is not set or array is smaller than batch size, process all at once
        if (self.batchSize == 0 || self.numberOfCurrencies <= self.batchSize) {
            for (uint256 i = 0; i < self.numberOfCurrencies; i++) {
                bytes memory currency = self.currencyIndexToCurrency[i];
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
    /// @return nextIndexToProcss The last processed index
    /// @return totalCurrencies The total number of currencies
    function getBatchProcessingState(
        PricingData storage self
    )
        internal
        view
        returns (uint256 nextIndexToProcss, uint256 totalCurrencies)
    {
        return (
            self.nextIndexToProcss % self.numberOfCurrencies,
            self.numberOfCurrencies
        );
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

    /// @notice Get the prices of a list of currencies
    /// @param currencies The list of currencies to get the prices of
    /// @return prices The list of prices for the currencies requested
    function getCurrencyPrices(
        PricingData storage self,
        bytes[] memory currencies
    ) internal view returns (uint256[] memory prices) {
        uint256 length = currencies.length;
        prices = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            prices[i] = self.currencyPrice[currencies[i]];
        }

        return prices;
    }

    /// @notice Check if a currency exists
    /// @param currency The currency to check
    /// @return exists Whether the currency exists
    function currencyExists(
        PricingData storage self,
        bytes memory currency
    ) internal view returns (bool) {
        return self.currencyPrice[currency] > 0;
    }

    /// @notice Remove a currency from the pricing data
    /// @param currency The currency to remove
    /// @dev This function will not remove the anchor currency and will revert if the currency is the anchor
    /// @dev This function will also revert if the currency is not found, if price is not set or if the currency is empty
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
        if (index < self.numberOfCurrencies - 1) {
            self.currencyIndexToCurrency[index] = self.currencyIndexToCurrency[
                self.numberOfCurrencies - 1
            ];
            self.currencyIndex[self.currencyIndexToCurrency[index]] = index;
        }
        self.numberOfCurrencies--;
        delete self.currencyIndex[currency];
        delete self.currencyPrice[currency];

        emit CurrencyRemoved(currency);
    }
}
