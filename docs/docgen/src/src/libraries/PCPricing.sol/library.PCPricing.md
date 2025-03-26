# PCPricing
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/c6910cb2f39a70e501a7e10629806c01450b8f08/src/libraries/PCPricing.sol)

**Author:**
Permissionless Games & ChatGpt

This library enables dynamic price adjustments based on preferred currency usage.

*When the anchor currency is used, the price of all other tracked currencies can be decreased.
A universal adjustment factor applies to all non-anchor currencies, promoting dynamic pricing models.*


## Functions
### setAnchorCurrency

Set the anchor currency and its initial price

*This function is used to set the anchor currency and its initial price can only be called once*


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

Update the universal adjustment percentage for a specific currency


```solidity
function setAdjustmentFactor(PricingData storage self, bytes memory currency, uint256 numerator, uint256 denominator)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currency`|`bytes`||
|`numerator`|`uint256`|The numerator of the adjustment factor|
|`denominator`|`uint256`|The denominator of the adjustment factor|


### addCurrency


```solidity
function addCurrency(
    PricingData storage self,
    bytes memory currency,
    uint256 price,
    uint256 numerator,
    uint256 denominator
) internal;
```

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

adjust the price of non-anchor currencies based on batch size


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
|`<none>`|`uint256`|uint256 Number of currencies processed in this update|


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

*If the number of currencies exceed the batchsize, it will instead only process the batchsize*


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


### getCurrencyPrices

Get the prices of a list of currencies


```solidity
function getCurrencyPrices(PricingData storage self, bytes[] memory currencies)
    internal
    view
    returns (uint256[] memory prices);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`PricingData`||
|`currencies`|`bytes[]`|The list of currencies to get the prices of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`prices`|`uint256[]`|The list of prices for the currencies requested|


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

*This function will not remove the anchor currency and will revert if the currency is the anchor*

*This function will also revert if the currency is not found, if price is not set or if the currency is empty*


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
    mapping(bytes => uint256) adjustmentNumerator;
    mapping(bytes => uint256) adjustmentDenominator;
    mapping(bytes => uint256) currencyPrice;
    mapping(bytes => uint256) currencyIndex;
    uint256 numberOfCurrencies;
    mapping(uint256 => bytes) currencyIndexToCurrency;
    uint256 lastProcessedIndex;
    uint256 batchSize;
}
```

