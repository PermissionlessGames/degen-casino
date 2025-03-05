# MCTOwnership
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/07e085d78604956185646dcea17b77558172ed4c/src/token/ERC20/extensions/MCTOwnership.sol)

**Inherits:**
Ownable, [MultipleCurrencyToken](/src/token/ERC20/MultipleCurrencyToken.sol/contract.MultipleCurrencyToken.md)


## Functions
### adjustPricingData


```solidity
function adjustPricingData(uint256 _pricingDataIndex, uint256 _newPrice) external onlyOwner;
```

### adjustAdjustmentFactor


```solidity
function adjustAdjustmentFactor(uint256 _numerator, uint256 _denominator) external onlyOwner;
```

### addNewPricingData


```solidity
function addNewPricingData(CreatePricingDataParams[] memory _createPricingDataParams) external onlyOwner;
```

### removePricingData


```solidity
function removePricingData(uint256 _pricingDataIndex) external onlyOwner;
```

