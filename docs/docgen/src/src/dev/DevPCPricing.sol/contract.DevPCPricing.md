# DevPCPricing
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/5267dc482ea6e0862309fefb038ca0fcb441799e/src/dev/DevPCPricing.sol)

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
function useAnchorCurrency() external;
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

## Events
### PriceUpdated

```solidity
event PriceUpdated(bytes indexed currency, uint256 newPrice);
```

### AllPricesReduced

```solidity
event AllPricesReduced();
```

