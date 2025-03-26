# DevPCPricing
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/c6910cb2f39a70e501a7e10629806c01450b8f08/src/dev/DevPCPricing.sol)

**Author:**
Permissionless Games & ChatGPT

This contract is for debugging and testing the PCPricing library on test networks.

*Allows setting, adjusting, and retrieving currency prices in a simulated test environment.*


## State Variables
### pricingData

```solidity
PCPricing.PricingData private pricingData;
```


## Functions
### constructor

Constructor initializes the anchor currency and default adjustment factor


```solidity
constructor(bytes memory anchorCurrency, uint256 anchorPrice, uint256 batchSize);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`anchorCurrency`|`bytes`|The anchor currency (e.g., ETH)|
|`anchorPrice`|`uint256`|The starting price of the anchor currency|
|`batchSize`|`uint256`||


### addCurrency

Add a new currency to the system


```solidity
function addCurrency(bytes memory currency, uint256 price, uint256 numerator, uint256 denominator) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency to add|
|`price`|`uint256`|The price of the currency|
|`numerator`|`uint256`|The numerator of the adjustment percentage|
|`denominator`|`uint256`|The denominator of the adjustment percentage|


### setCurrencyPrice

Set a new currency price


```solidity
function setCurrencyPrice(bytes memory currency, uint256 price) external;
```

### adjustCurrencyPrice

Manually adjust a currency price


```solidity
function adjustCurrencyPrice(bytes memory currency, bool increase) external;
```

### useAnchorCurrency

Reduce all non-anchor currency prices when the anchor is used

*WARNING: This function may hit gas limits with large currency arrays*


```solidity
function useAnchorCurrency(bool increase) external;
```

### adjustNonAnchorPricesBatch

Process a batch of non-anchor currency price adjustments


```solidity
function adjustNonAnchorPricesBatch(bool increase, uint256 batchSize) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`increase`|`bool`|Whether to increase or decrease prices|
|`batchSize`|`uint256`|Maximum number of currencies to process|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|processedCount Number of currencies processed|


### getBatchProcessingState

Get the current state of batch processing


```solidity
function getBatchProcessingState() external view returns (uint256 lastProcessedIndex, uint256 totalCurrencies);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lastProcessedIndex`|`uint256`|The index where processing will resume|
|`totalCurrencies`|`uint256`|Total number of tracked currencies|


### getCurrencyPrice

Get a specific currency price


```solidity
function getCurrencyPrice(bytes memory currency) external view returns (uint256);
```

### getCurrencyPrices

Retrieve all stored currency prices


```solidity
function getCurrencyPrices(bytes[] memory currencies) external view returns (uint256[] memory);
```

### setAdjustmentFactor


```solidity
function setAdjustmentFactor(bytes memory currency, uint256 numerator, uint256 denominator) external;
```

### getAdjustmentFactor

Get the adjustment factor for a specific currency


```solidity
function getAdjustmentFactor(bytes memory currency) external view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency to get the adjustment factor for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|numerator The numerator of the adjustment factor|
|`<none>`|`uint256`|denominator The denominator of the adjustment factor|


### getAnchorCurrency

Get the anchor currency


```solidity
function getAnchorCurrency() external view returns (bytes memory);
```

### getCurrencyIndex

Get the index of a specific currency


```solidity
function getCurrencyIndex(bytes memory currency) external view returns (uint256);
```

### currencyExists

Check if a currency exists in the system


```solidity
function currencyExists(bytes memory currency) external view returns (bool);
```

### removeCurrency

Remove a currency from the system


```solidity
function removeCurrency(bytes memory currency) external;
```

### setBatchSize

Set the batch size for processing large arrays of currencies


```solidity
function setBatchSize(uint256 newBatchSize) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newBatchSize`|`uint256`|The maximum number of currencies to process in a single batch|


### getBatchSize

Get the current batch size setting


```solidity
function getBatchSize() external view returns (uint256);
```

### getIndexToCurrency

Get the currency at a specific index


```solidity
function getIndexToCurrency(uint256 index) external view returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|currency The currency at the index|


### getCurrencyIndexToCurrency

Get the index of a specific currency


```solidity
function getCurrencyIndexToCurrency(bytes memory currency) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The currency to get the index of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|index The index of the currency|


### getNumberOfCurrencies

Get the number of currencies in the system


```solidity
function getNumberOfCurrencies() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|numberOfCurrencies The number of currencies in the system|


