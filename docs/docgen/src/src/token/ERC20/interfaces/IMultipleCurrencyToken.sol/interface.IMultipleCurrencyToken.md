# IMultipleCurrencyToken
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/9c34e699d207213995d107c8fd4b5f0accbbff0b/src/token/ERC20/interfaces/IMultipleCurrencyToken.sol)


## Functions
### tokens

Get the token configuration at a specific index


```solidity
function tokens(uint256 index) external view returns (CreatePricingDataParams memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the token configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`CreatePricingDataParams`|token The token configuration|


### INATIVE

Get the address of the native token


```solidity
function INATIVE() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The address of the native token|


### encodeCurrency

Encode a currency into a bytes array


```solidity
function encodeCurrency(MCTTokens memory currency) external pure returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`MCTTokens`|The address of the currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|currencyBytes The encoded currency|


### getMintPrice

Get the mint price for a currency


```solidity
function getMintPrice(bytes memory currency) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The encoded currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The mint price|


### getRedeemPrice

Get the redeem price for a currency


```solidity
function getRedeemPrice(bytes memory currency) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The encoded currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The redeem price|


### deposit

Deposit a currency


```solidity
function deposit(MCTTokens memory currency, uint256 amount) external payable returns (uint256 mintAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`MCTTokens`|The address of the currency|
|`amount`|`uint256`|The amount to deposit|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`mintAmount`|`uint256`|The amount minted|


### withdraw

Withdraw a currency


```solidity
function withdraw(MCTTokens memory currency, uint256 amountIn) external returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`MCTTokens`|The address of the currency|
|`amountIn`|`uint256`|The amount to withdraw|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount withdrawn|


### estimateDepositAmount

Estimate the deposit amount for a currency


```solidity
function estimateDepositAmount(MCTTokens memory currency, uint256 depositAmount)
    external
    view
    returns (uint256 amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`MCTTokens`|The address of the currency|
|`depositAmount`|`uint256`|The amount to deposit|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The estimated deposit amount|


### getTokens

Get the token configurations


```solidity
function getTokens()
    external
    view
    returns (address[] memory currencies, uint256[] memory tokenIds, bool[] memory is1155);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|The addresses of the currencies|
|`tokenIds`|`uint256[]`|The token IDs|
|`is1155`|`bool[]`|The booleans indicating if the tokens are ERC1155|


### doesCurrencyExist

Check if a currency exists


```solidity
function doesCurrencyExist(MCTTokens memory currency) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`MCTTokens`|The address of the currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|exists Boolean indicating if the currency exists|


### amountNeededToMint

Get the amount needed to mint a currency


```solidity
function amountNeededToMint(uint256 requestingAmount, MCTTokens memory currency)
    external
    view
    returns (uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestingAmount`|`uint256`|The amount of tokens to mint|
|`currency`|`MCTTokens`|The address of the currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount The amount needed to mint|
|`<none>`|`bool`||


### amountWantedToRedeem

Get the amount wanted to redeem a currency


```solidity
function amountWantedToRedeem(uint256 requestingAmount, MCTTokens memory currency)
    external
    view
    returns (uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestingAmount`|`uint256`|The amount of tokens to redeem|
|`currency`|`MCTTokens`|The address of the currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount The amount needed to redeem the requested amount|
|`<none>`|`bool`|exists Boolean indicating if the currency exists|


## Events
### NewPricingDataAdded
Event emitted when new pricing data is added


```solidity
event NewPricingDataAdded(CreatePricingDataParams pricingData);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pricingData`|`CreatePricingDataParams`|The new pricing data|

