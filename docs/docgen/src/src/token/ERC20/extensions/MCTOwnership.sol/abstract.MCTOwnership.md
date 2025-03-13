# MCTOwnership
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/5b8912b5f619f9a0fd41d05116c74827e1377fb4/src/token/ERC20/extensions/MCTOwnership.sol)

**Inherits:**
Ownable, [MultipleCurrencyToken](/src/token/ERC20/MultipleCurrencyToken.sol/contract.MultipleCurrencyToken.md)


## Functions
### constructor

Constructor for the MCTOwnership contract


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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name of the token|
|`symbol_`|`string`|The symbol of the token|
|`inative`|`address`|The address of the native currency|
|`adjustmentNumerator`|`uint256`|The numerator of the adjustment factor|
|`adjustmentDenominator`|`uint256`|The denominator of the adjustment factor|
|`currencies`|`CreatePricingDataParams[]`|The currencies to add to the token|


### adjustPricingData

Adjust the pricing data for a currency


```solidity
function adjustPricingData(uint256 _pricingDataIndex, uint256 _newPrice) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pricingDataIndex`|`uint256`|The index of the pricing data to adjust|
|`_newPrice`|`uint256`|The new price of the currency|


### adjustAdjustmentFactor

Adjust the adjustment factor for the token


```solidity
function adjustAdjustmentFactor(uint256 _numerator, uint256 _denominator) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_numerator`|`uint256`|The numerator of the adjustment factor|
|`_denominator`|`uint256`|The denominator of the adjustment factor|


### addNewPricingData

Add new pricing data for a currency


```solidity
function addNewPricingData(IMultipleCurrencyToken.CreatePricingDataParams[] memory _createPricingDataParams)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_createPricingDataParams`|`IMultipleCurrencyToken.CreatePricingDataParams[]`|The pricing data to add|


### removePricingData

Remove pricing data for a currency


```solidity
function removePricingData(uint256 _pricingDataIndex) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pricingDataIndex`|`uint256`|The index of the pricing data to remove|


