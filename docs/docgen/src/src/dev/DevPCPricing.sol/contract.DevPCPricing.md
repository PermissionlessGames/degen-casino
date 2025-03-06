# DevPCPricing
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/92c3c13d3e6a66ec5e6832bad4bf33e9ff24b4f2/src/dev/DevPCPricing.sol)

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
constructor(bytes memory anchorCurrency, uint256 anchorPrice, uint256 adjNumerator, uint256 adjDenominator);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`anchorCurrency`|`bytes`|The anchor currency (e.g., ETH)|
|`anchorPrice`|`uint256`|The starting price of the anchor currency|
|`adjNumerator`|`uint256`|The numerator of the adjustment percentage|
|`adjDenominator`|`uint256`|The denominator of the adjustment percentage|


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


```solidity
function useAnchorCurrency(bool increase) external;
```

### getCurrencyPrice

Get a specific currency price


```solidity
function getCurrencyPrice(bytes memory currency) external view returns (uint256);
```

### getAllCurrencyPrices

Retrieve all stored currency prices


```solidity
function getAllCurrencyPrices() external view returns (bytes[] memory, uint256[] memory);
```

### getAdjustmentFactor


```solidity
function getAdjustmentFactor() external view returns (uint256, uint256);
```

### getAnchorCurrency

Get the anchor currency


```solidity
function getAnchorCurrency() external view returns (bytes memory);
```

### getTrackedCurrencies

Get all tracked non-anchor currencies


```solidity
function getTrackedCurrencies() external view returns (bytes[] memory);
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

