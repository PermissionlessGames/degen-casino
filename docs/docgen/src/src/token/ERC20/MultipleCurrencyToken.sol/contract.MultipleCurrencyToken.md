# MultipleCurrencyToken
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/8c111e031dce22e9b3adb986428659289f9e12a7/src/token/ERC20/MultipleCurrencyToken.sol)

**Inherits:**
ERC20, ReentrancyGuard, ERC1155Holder, [IMultipleCurrencyToken](/src/token/ERC20/interfaces/IMultipleCurrencyToken.sol/interface.IMultipleCurrencyToken.md)


## State Variables
### mintPricingData

```solidity
PCPricing.PricingData mintPricingData;
```


### redeemPricingData

```solidity
PCPricing.PricingData redeemPricingData;
```


### INATIVE

```solidity
address public immutable INATIVE;
```


### tokenIs1155

```solidity
mapping(address => bool) public tokenIs1155;
```


### _tokens

```solidity
CreatePricingDataParams[] private _tokens;
```


## Functions
### tokens


```solidity
function tokens(uint256 index) public view override returns (CreatePricingDataParams memory);
```

### constructor

Constructor for PCPricedToken

*The first currency in the array is set as the anchor currency with its price as the anchor price*

*All other currencies are initialized with their specified prices relative to the anchor*

*Both mint and redeem pricing data are initialized with the same adjustment factors*


```solidity
constructor(
    string memory name_,
    string memory symbol_,
    address inative,
    uint256 adjustmentNumerator,
    uint256 adjustmentDenominator,
    CreatePricingDataParams[] memory currencies
) ERC20(name_, symbol_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name of the token|
|`symbol_`|`string`|The symbol of the token|
|`inative`|`address`|The address used to identify native deposits (e.g. ETH)|
|`adjustmentNumerator`|`uint256`|The numerator for price adjustment calculations|
|`adjustmentDenominator`|`uint256`|The denominator for price adjustment calculations|
|`currencies`|`CreatePricingDataParams[]`|Array of CreatePricingDataParams containing initial currency/token configurations|


### addNewPricingData


```solidity
function addNewPricingData(CreatePricingDataParams memory _createPricingDataParams) internal;
```

### deposit

Deposit tokens to mint PCPTokens

*For each token:*

*- If native currency (ETH), amount must match msg.value*

*- If ERC1155, transfers specified tokenId and amount*

*- If ERC20, transfers specified amount*

*Mints PCPTokens based on deposit value calculated from pricing data*


```solidity
function deposit(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory amounts)
    external
    payable
    nonReentrant
    returns (uint256 mintAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|Array of token addresses to deposit (use INATIVE for native currency)|
|`tokenIds`|`uint256[]`|Array of token IDs for ERC1155 tokens (ignored for ERC20)|
|`amounts`|`uint256[]`|Array of amounts to deposit for each token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`mintAmount`|`uint256`|The amount of PCPTokens minted|


### depositTokens

Internal function to handle token deposits


```solidity
function depositTokens(
    address[] memory currencies,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    address caller,
    uint256 msgValue
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|Array of token addresses to deposit (use INATIVE for native currency)|
|`tokenIds`|`uint256[]`|Array of token IDs for ERC1155 tokens (ignored for ERC20)|
|`amounts`|`uint256[]`|Array of amounts to deposit for each token|
|`caller`|`address`|Address initiating the deposit|
|`msgValue`|`uint256`|Native currency value sent with transaction|


### estimateDepositAmount

Estimate the amount of tokens to be minted based on currency price


```solidity
function estimateDepositAmount(address[] memory currencies, uint256[] memory tokenIds, uint256[] memory deposits)
    public
    view
    returns (uint256 amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currencies`|`address[]`|Array of currency addresses to deposit|
|`tokenIds`|`uint256[]`|Array of token IDs for ERC1155 tokens (ignored for ERC20)|
|`deposits`|`uint256[]`|Array of amounts to deposit for each currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The estimated amount of tokens to be minted|


### withdraw

Withdraw tokens from the contract

*Burns PCP tokens and returns the underlying assets*

*If currency is not the anchor currency, its price is decreased*

*If currency is the anchor currency, all other currency prices are increased*

*For ERC1155 tokens, uses safeTransferFrom*

*For ERC20 tokens, uses safeTransfer*

*For native, uses call*


```solidity
function withdraw(address currency, uint256 tokenId, uint256 amountIn)
    external
    nonReentrant
    returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`address`|The address of the currency to withdraw|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`amountIn`|`uint256`|The amount of PCP tokens to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount of tokens withdrawn|


### estimateWithdrawAmount

Estimate the amount of tokens to be withdrawn based on currency price


```solidity
function estimateWithdrawAmount(address currency, uint256 tokenId, uint256 amountIn)
    public
    view
    returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`address`|The address of the currency to withdraw|
|`tokenId`|`uint256`|The token ID for ERC1155 tokens (ignored for ERC20)|
|`amountIn`|`uint256`|The amount of PCP tokens to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The estimated amount of tokens to be withdrawn|


### getTokens

Get the list of tokens and their properties


```solidity
function getTokens() external view returns (address[] memory, uint256[] memory, bool[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|currencies Array of token addresses|
|`<none>`|`uint256[]`|tokenIds Array of token IDs|
|`<none>`|`bool[]`|is1155 Array of booleans indicating if the token is an ERC1155|


### getTokenPriceRatios

Get the price ratios for minting and redeeming


```solidity
function getTokenPriceRatios(address[] memory treasuryTokens, uint256[] memory tokenIds)
    external
    view
    returns (uint256[] memory, uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`treasuryTokens`|`address[]`|Array of token addresses to get price ratios for|
|`tokenIds`|`uint256[]`|Array of token IDs for ERC1155 tokens (ignored for ERC20)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|mintPriceRatios Array of mint price ratios|
|`<none>`|`uint256[]`|redeemPriceRatios Array of redeem price ratios|


### encodeCurrency


```solidity
function encodeCurrency(address currency, uint256 tokenId, bool is1155) public pure override returns (bytes memory);
```

### getMintPrice


```solidity
function getMintPrice(bytes memory currency) public view override returns (uint256);
```

### getRedeemPrice


```solidity
function getRedeemPrice(bytes memory currency) public view override returns (uint256);
```

