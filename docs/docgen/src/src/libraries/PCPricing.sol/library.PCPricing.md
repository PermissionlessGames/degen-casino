# PCPricing
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/5b3f6eb76c1e4fe356f64ba26f9e9f5dfc4b0f60/src/libraries/PCPricing.sol)

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

### reduceAllNonAnchorPrices

Reduce the price of all non-anchor currencies when the anchor currency is used


```solidity
function reduceAllNonAnchorPrices(PricingData storage self) internal;
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

## Structs
### PricingData

```solidity
struct PricingData {
    bytes anchorCurrency;
    uint256 adjustmentNumerator;
    uint256 adjustmentDenominator;
    mapping(bytes => uint256) currencyPrice;
    bytes[] trackedCurrencies;
}
```

