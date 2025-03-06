# MCTOwnership
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/8c111e031dce22e9b3adb986428659289f9e12a7/src/token/ERC20/extensions/MCTOwnership.sol)

**Inherits:**
Ownable, [MultipleCurrencyToken](/src/token/ERC20/MultipleCurrencyToken.sol/contract.MultipleCurrencyToken.md)


## Functions
### constructor


```solidity
constructor(
    string memory name_,
    string memory symbol_,
    address inative,
    uint256 adjustmentNumerator,
    uint256 adjustmentDenominator,
    CreatePricingDataParams[] memory currencies
)
    MultipleCurrencyToken(name_, symbol_, inative, adjustmentNumerator, adjustmentDenominator, currencies)
    Ownable(msg.sender);
```

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
function addNewPricingData(IMultipleCurrencyToken.CreatePricingDataParams[] memory _createPricingDataParams)
    external
    onlyOwner;
```

### removePricingData


```solidity
function removePricingData(uint256 _pricingDataIndex) external onlyOwner;
```

