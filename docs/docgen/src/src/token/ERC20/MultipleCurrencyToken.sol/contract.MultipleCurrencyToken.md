# MultipleCurrencyToken
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/5b8912b5f619f9a0fd41d05116c74827e1377fb4/src/token/ERC20/MultipleCurrencyToken.sol)

**Inherits:**
ERC20, ReentrancyGuard, ERC1155Holder, [IMultipleCurrencyToken](/src/token/ERC20/interfaces/IMultipleCurrencyToken.sol/interface.IMultipleCurrencyToken.md)


## State Variables
### mintPricingData
SafeERC20 library for ERC20 token operations

PCPricing library for pricing data operations

Pricing data for minting


```solidity
PCPricing.PricingData mintPricingData;
```


### redeemPricingData
Pricing data for redeeming


```solidity
PCPricing.PricingData redeemPricingData;
```


### INATIVE
Address used to identify native deposits


```solidity
address public immutable INATIVE;
```


### tokenIs1155
Mapping of token addresses to booleans indicating if they are ERC1155


```solidity
mapping(address => bool) public tokenIs1155;
```


### _tokens
Array of token configurations


```solidity
CreatePricingDataParams[] private _tokens;
```


### _decimals

```solidity
uint256 _decimals;
```


## Functions
### tokens

Get the token configuration at a specific index


```solidity
function tokens(uint256 index) public view virtual override returns (CreatePricingDataParams memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the token configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`CreatePricingDataParams`|token The token configuration|


### constructor

Constructor for PCPricedToken

*The first currency in the array is set as the anchor currency with its price as the anchor price*

*All other currencies are initialized with their specified prices relative to the anchor*

*Both mint and redeem pricing data are initialized with the same adjustment factors*

*The decimals of the token are set to the number of decimals of the anchor currency*

*The token is initialized with the initial pricing data*


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

Add new pricing data for a currency


```solidity
function addNewPricingData(CreatePricingDataParams memory _createPricingDataParams) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_createPricingDataParams`|`CreatePricingDataParams`|The pricing data to add|


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
    virtual
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
) internal virtual;
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
    virtual
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
    virtual
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
function getTokens() external view virtual returns (address[] memory, uint256[] memory, bool[] memory);
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
    virtual
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

Encode a currency into a bytes array


```solidity
function encodeCurrency(address currency, uint256 tokenId, bool is1155) public pure virtual returns (bytes memory);
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
function getMintPrice(bytes memory currency) public view virtual returns (uint256);
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
function getRedeemPrice(bytes memory currency) public view virtual returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`bytes`|The encoded currency|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The redeem price|


### doesCurrencyExist

Check if a currency exists


```solidity
function doesCurrencyExist(address currency, uint256 tokenId, bool is1155) public view virtual returns (bool);
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
    public
    view
    virtual
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
    public
    view
    virtual
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


### receive

Receive function to allow contract to receive native currency


```solidity
receive() external payable;
```

