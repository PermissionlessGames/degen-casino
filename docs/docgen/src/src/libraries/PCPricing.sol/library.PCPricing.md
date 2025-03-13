# PCPricing
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/e51575ec321323c4f0687ab65549f1df9bfb5f4b/src/libraries/PCPricing.sol)

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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`|The currency to set as the anchor|
|`price`|`uint256`|The initial price of the anchor currency|


### setAdjustmentFactor

Set the universal adjustment percentage for all non-anchor currencies


```solidity
function setAdjustmentFactor(PricingData storage self, uint256 numerator, uint256 denominator) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`numerator`|`uint256`|The numerator of the adjustment factor|
|`denominator`|`uint256`|The denominator of the adjustment factor|


### setCurrencyPrice

Set the initial price for a specific currency


```solidity
function setCurrencyPrice(PricingData storage self, bytes memory currency, uint256 price) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`|The currency to set the price for|
|`price`|`uint256`|The price to set for the currency|


### adjustCurrencyPrice

Adjust the price dynamically based on usage (same adjustment for all non-anchor currencies)


```solidity
function adjustCurrencyPrice(PricingData storage self, bytes memory currency, bool increase) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`||
|`increase`|`bool`|Whether to increase or decrease the price|


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
|`increase`|`bool`|Whether to increase or decrease the price|
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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`newBatchSize`|`uint256`|The new batch size|


### adjustAllNonAnchorPrices

Legacy function that adjusts all prices in one transaction

*If trackedCurrencies length exceeds batchSize, it will use batch processing*


```solidity
function adjustAllNonAnchorPrices(PricingData storage self, bool increase) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`increase`|`bool`|Whether to increase or decrease the price|


### getBatchProcessingState

Get the current batch processing state


```solidity
function getBatchProcessingState(PricingData storage self)
    internal
    view
    returns (uint256 lastProcessedIndex, uint256 totalCurrencies);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lastProcessedIndex`|`uint256`|The last processed index|
|`totalCurrencies`|`uint256`|The total number of currencies|


### getCurrencyPrice

Get the current price of a currency


```solidity
function getCurrencyPrice(PricingData storage self, bytes memory currency) internal view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`|The currency to get the price of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|The price of the currency|


### getAllCurrencyPrices

Get all tracked currency prices


```solidity
function getAllCurrencyPrices(PricingData storage self) internal view returns (bytes[] memory, uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes[]`|currencies The list of tracked currencies|
|`<none>`|`uint256[]`|prices The list of prices for the tracked currencies|


### currencyExists

Check if a currency exists


```solidity
function currencyExists(PricingData storage self, bytes memory currency) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`|The currency to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|exists Whether the currency exists|


### removeCurrency

Remove a currency from the pricing data


```solidity
function removeCurrency(PricingData storage self, bytes memory currency) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`|The currency to remove|


## Events
### AnchorCurrencySet
Emitted when a new anchor currency is set


```solidity
event AnchorCurrencySet(bytes indexed currency, uint256 price);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency that was set as the anchor|
|`price`|`uint256`|The price of the anchor currency|

### AdjustmentFactorSet
Emitted when the adjustment factor is updated


```solidity
event AdjustmentFactorSet(uint256 numerator, uint256 denominator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`numerator`|`uint256`|The numerator of the adjustment factor|
|`denominator`|`uint256`|The denominator of the adjustment factor|

### CurrencyPriceSet
Emitted when a new currency price is set


```solidity
event CurrencyPriceSet(bytes indexed currency, uint256 price);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency that was set|
|`price`|`uint256`|The price of the currency|

### CurrencyPriceAdjusted
Emitted when a currency price is adjusted


```solidity
event CurrencyPriceAdjusted(bytes indexed currency, uint256 newPrice, bool increased);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency that was adjusted|
|`newPrice`|`uint256`|The new price of the currency|
|`increased`|`bool`|Whether the price was increased or decreased|

### CurrencyRemoved
Emitted when a currency is removed


```solidity
event CurrencyRemoved(bytes indexed currency);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency that was removed|

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
Struct for pricing data


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

