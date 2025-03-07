# PCPricing
<<<<<<< HEAD
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/cf1c5ca470c688d20285ece4b239db87eca65887/src/libraries/PCPricing.sol)
=======
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/8e3c49ec1b47ecdb92bceb56c31f5683f84e9463/src/libraries/PCPricing.sol)
>>>>>>> preferred-currency-pricing

**Author:**
Permissionless Games & ChatGpt

This library enables dynamic price adjustments based on preferred currency usage.

*When the anchor currency is used, the price of all other tracked currencies can be decreased.
A universal adjustment factor applies to all non-anchor currencies, promoting dynamic pricing models.*


## Functions
### setAnchorCurrency

Set the anchor currency and its initial price


```solidity
function setAnchorCurrency(PricingData storage self, bytes memory currency, uint256 price) internal;
```

### setAdjustmentFactor

Set the universal adjustment percentage for all non-anchor currencies


```solidity
function setAdjustmentFactor(PricingData storage self, uint256 numerator, uint256 denominator) internal;
```

### setCurrencyPrice

Set the initial price for a specific currency


```solidity
function setCurrencyPrice(PricingData storage self, bytes memory currency, uint256 price) internal;
```

### adjustCurrencyPrice

Adjust the price dynamically based on usage (same adjustment for all non-anchor currencies)


```solidity
function adjustCurrencyPrice(PricingData storage self, bytes memory currency, bool increase) internal;
```

### adjustNonAnchorPricesBatch

adjust the price of a batch of non-anchor currencies


```solidity
function adjustNonAnchorPricesBatch(PricingData storage self, bool increase, uint256 batchSize)
    internal
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`increase`|`bool`||
|`batchSize`|`uint256`|Maximum number of currencies to process in this transaction|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|(processedCount, hasMore) Number of currencies processed and whether there are more to process|


### setBatchSize

Set the batch size for processing large arrays of currencies


```solidity
function setBatchSize(PricingData storage self, uint256 newBatchSize) internal;
```

### adjustAllNonAnchorPrices

Legacy function that adjusts all prices in one transaction

*If trackedCurrencies length exceeds batchSize, it will use batch processing*


```solidity
function adjustAllNonAnchorPrices(PricingData storage self, bool increase) internal;
```

### getBatchProcessingState

Get the current batch processing state


```solidity
function getBatchProcessingState(PricingData storage self)
    internal
    view
    returns (uint256 lastProcessedIndex, uint256 totalCurrencies);
```

### getCurrencyPrice

Get the current price of a currency


```solidity
function getCurrencyPrice(PricingData storage self, bytes memory currency) internal view returns (uint256 price);
```

### getAllCurrencyPrices

Get all tracked currency prices


```solidity
function getAllCurrencyPrices(PricingData storage self) internal view returns (bytes[] memory, uint256[] memory);
```

### currencyExists


```solidity
function currencyExists(PricingData storage self, bytes memory currency) internal view returns (bool);
```

### removeCurrency


```solidity
function removeCurrency(PricingData storage self, bytes memory currency) internal;
```

## Events
### AnchorCurrencySet
Emitted when a new anchor currency is set


```solidity
event AnchorCurrencySet(bytes indexed currency, uint256 price);
```

### AdjustmentFactorSet
Emitted when the adjustment factor is updated


```solidity
event AdjustmentFactorSet(uint256 numerator, uint256 denominator);
```

### CurrencyPriceSet
Emitted when a new currency price is set


```solidity
event CurrencyPriceSet(bytes indexed currency, uint256 price);
```

### CurrencyPriceAdjusted
Emitted when a currency price is adjusted


```solidity
event CurrencyPriceAdjusted(bytes indexed currency, uint256 newPrice, bool increased);
```

### CurrencyRemoved
Emitted when a currency is removed


```solidity
event CurrencyRemoved(bytes indexed currency);
```

### NonAnchorPricesReduced
Emitted when all non-anchor prices are reduced


```solidity
event NonAnchorPricesReduced();
```

### NonAnchorPricesAdjustedBatch
Emitted when a batch of non-anchor prices are adjusted


```solidity
event NonAnchorPricesAdjustedBatch(uint256 processedCount, uint256 nextIndex);
```

## Structs
### PricingData

```solidity
struct PricingData {
    bytes anchorCurrency;
    uint256 adjustmentNumerator;
    uint256 adjustmentDenominator;
    mapping(bytes => uint256) currencyPrice;
    mapping(bytes => uint256) currencyIndex;
    bytes[] trackedCurrencies;
    uint256 lastProcessedIndex;
    uint256 batchSize;
}
```

