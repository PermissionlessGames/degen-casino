# IMultipleCurrencyToken
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/e51575ec321323c4f0687ab65549f1df9bfb5f4b/src/token/ERC20/interfaces/IMultipleCurrencyToken.sol)


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


### encodeCurrency

Encode a currency into a bytes array


```solidity
function encodeCurrency(address currency, uint256 tokenId, bool is1155) external pure returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`address`|The address of the currency|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`is1155`|`bool`|Boolean indicating if the token is an ERC1155|

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
function deposit(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory amounts)
    external
    payable
    returns (uint256 mintAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|The addresses of the currencies|
|`tokenIds`|`uint256[]`|The token IDs|
|`amounts`|`uint256[]`|The amounts to deposit|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`mintAmount`|`uint256`|The amount minted|


### withdraw

Withdraw a currency


```solidity
function withdraw(address currency, uint256 tokenId, uint256 amountIn) external returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`address`|The address of the currency|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`amountIn`|`uint256`|The amount to withdraw|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount withdrawn|


### estimateDepositAmount

Estimate the deposit amount for a currency


```solidity
function estimateDepositAmount(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory deposits)
    external
    view
    returns (uint256 amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|The addresses of the currencies|
|`tokenIds`|`uint256[]`|The token IDs|
|`deposits`|`uint256[]`|The amounts to deposit|

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
function doesCurrencyExist(address currency, uint256 tokenId, bool is1155) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`address`|The address of the currency|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`is1155`|`bool`|Boolean indicating if the token is an ERC1155|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|exists Boolean indicating if the currency exists|


### amountNeededToMint

Get the amount needed to mint a currency


```solidity
function amountNeededToMint(uint256 requestingAmount, address currency, uint256 tokenId, bool is1155)
    external
    view
    returns (uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestingAmount`|`uint256`|The amount of tokens to mint|
|`currency`|`address`|The address of the currency|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`is1155`|`bool`|Boolean indicating if the token is an ERC1155|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount The amount needed to mint|
|`<none>`|`bool`||


### amountWantedToRedeem

Get the amount wanted to redeem a currency


```solidity
function amountWantedToRedeem(uint256 requestingAmount, address currency, uint256 tokenId, bool is1155)
    external
    view
    returns (uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestingAmount`|`uint256`|The amount of tokens to redeem|
|`currency`|`address`|The address of the currency|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`is1155`|`bool`|Boolean indicating if the token is an ERC1155|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount The amount needed to redeem requested amount|
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

## Structs
### CreatePricingDataParams
Struct defining the parameters for creating pricing data


```solidity
struct CreatePricingDataParams {
    address currency;
    uint256 price;
    bool is1155;
    uint256 tokenId;
}
```

