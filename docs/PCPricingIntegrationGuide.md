# The *PCPricing* Integration Guide

This document describes how to integrate and use the `PCPricing` library in your smart contracts. The library provides dynamic price adjustment functionality based on preferred currency usage, making it ideal for multi-currency systems.

Interacting with `PCPricing`:
- Use the library directly in your smart contracts by importing it from `"../libraries/PCPricing.sol"`
- For testing purposes, you can use the [`DevPCPricing` contract](./src/dev/DevPCPricing.sol)

## Core Concepts

### Anchor Currency and Price Adjustments

The PCPricing library implements a dynamic pricing system where:
1. One currency is designated as the "anchor" currency
2. All other currencies are priced relative to this anchor
3. Prices can be adjusted up or down based on usage patterns
4. Adjustments are made using a configurable adjustment factor

The adjustment mechanism allows for automatic price modifications when certain conditions are met, such as:
- When the anchor currency is used frequently
- When specific currencies need price adjustments
- When batch processing of price updates is required

## Integration Flows

### 1. Setting Up PCPricing

To use PCPricing in your contract:

```solidity
import {PCPricing} from "../libraries/PCPricing.sol";

contract YourContract {
    using PCPricing for PCPricing.PricingData;
    PCPricing.PricingData private pricingData;

    constructor(bytes memory anchorCurrency, uint256 anchorPrice, uint256 adjNumerator, uint256 adjDenominator) {
        pricingData.setAnchorCurrency(anchorCurrency, anchorPrice);
        pricingData.setAdjustmentFactor(adjNumerator, adjDenominator);
    }
}
```

### 2. Managing Currencies

#### Adding New Currencies
To add a new currency to the system:

```solidity
function addCurrency(bytes memory currency, uint256 initialPrice) external {
    pricingData.setCurrencyPrice(currency, initialPrice);
}
```

#### Removing Currencies
To remove a currency from the system:

```solidity
function removeCurrency(bytes memory currency) external {
    pricingData.removeCurrency(currency);
}
```

### 3. Price Adjustments

#### Single Currency Adjustment
To adjust the price of a single currency:

```solidity
function adjustPrice(bytes memory currency, bool increase) external {
    pricingData.adjustCurrencyPrice(currency, increase);
}
```

#### Batch Price Adjustments
For large sets of currencies, use batch processing to avoid gas limits:

```solidity
function adjustPricesBatch(bool increase, uint256 batchSize) external returns (uint256) {
    return pricingData.adjustNonAnchorPricesBatch(increase, batchSize);
}
```

### 4. Querying Prices and State

#### Getting Currency Prices
To get the current price of a currency:

```solidity
function getPrice(bytes memory currency) external view returns (uint256) {
    return pricingData.getCurrencyPrice(currency);
}
```

#### Getting All Prices
To get all currency prices:

```solidity
function getAllPrices() external view returns (bytes[] memory currencies, uint256[] memory prices) {
    return pricingData.getAllCurrencyPrices();
}
```

## Events

The library emits several events that you can listen for:

1. `AnchorCurrencySet(bytes indexed currency, uint256 price)`
   - Emitted when a new anchor currency is set
   - Contains the currency identifier and its price

2. `AdjustmentFactorSet(uint256 numerator, uint256 denominator)`
   - Emitted when the adjustment factor is updated
   - Contains the new numerator and denominator values

3. `CurrencyPriceSet(bytes indexed currency, uint256 price)`
   - Emitted when a new currency price is set
   - Contains the currency identifier and its new price

4. `CurrencyPriceAdjusted(bytes indexed currency, uint256 newPrice, bool increased)`
   - Emitted when a currency price is adjusted
   - Contains the currency identifier, new price, and whether it was increased

5. `CurrencyRemoved(bytes indexed currency)`
   - Emitted when a currency is removed from the system
   - Contains the identifier of the removed currency

## Debugging with DevPCPricing

For testing and debugging purposes, you can use the `DevPCPricing` contract. This contract provides a complete implementation of the PCPricing library with additional debugging features.

### Setting Up DevPCPricing
```solidity
DevPCPricing devPricing = new DevPCPricing(
    "ETH",  // anchor currency
    1000,   // anchor price
    5,      // adjustment numerator (5%)
    100     // adjustment denominator
);
```

### Testing Functions
The `DevPCPricing` contract includes several testing functions:

1. Price Management:
```solidity
// Set a new currency price
devPricing.setCurrencyPrice("USDT", 100);

// Adjust a currency price
devPricing.adjustCurrencyPrice("USDT", true); // increase
devPricing.adjustCurrencyPrice("USDT", false); // decrease
```

2. Batch Operations:
```solidity
// Set batch size
devPricing.setBatchSize(50);

// Process a batch of price adjustments
devPricing.adjustNonAnchorPricesBatch(false, 50);
```

3. State Inspection:
```solidity
// Get current prices
uint256 price = devPricing.getCurrencyPrice("USDT");

// Check currency existence
bool exists = devPricing.currencyExists("USDT");

// Get batch processing state
(uint256 lastIndex, uint256 total) = devPricing.getBatchProcessingState();
```

## Best Practices

1. **Gas Optimization**
   - Use batch processing for large sets of currencies
   - Set appropriate batch sizes based on your needs
   - Consider gas costs when adjusting prices frequently

2. **Price Stability**
   - Choose appropriate adjustment factors
   - Monitor price changes over time
   - Implement safeguards against extreme price fluctuations

3. **Error Handling**
   - Always check if currencies exist before operations
   - Handle failed price adjustments gracefully
   - Implement access controls for price modifications

4. **Event Monitoring**
   - Listen for price adjustment events
   - Track batch processing progress
   - Monitor currency additions and removals 