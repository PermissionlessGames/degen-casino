# PCPricing
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/cf1c5ca470c688d20285ece4b239db87eca65887/src/libraries/PCPricing.sol)

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

### adjustAllNonAnchorPrices

adjust the price of all non-anchor currencies when the anchor currency is used


```solidity
function adjustAllNonAnchorPrices(PricingData storage self, bool increase) internal;
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
}
```

