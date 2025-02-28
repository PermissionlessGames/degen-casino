# PCPricedToken
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/760b4fc276a589a76aa0e7708831424a0d0591e7/src/token/PCPToken.sol)

**Inherits:**
ERC20, ReentrancyGuard


## State Variables
### pricingData

```solidity
PCPricing.PricingData private pricingData;
```


### INATIVE

```solidity
address public immutable INATIVE;
```


### tokens

```solidity
address[] public tokens;
```


## Functions
### constructor


```solidity
constructor(
    string memory name_,
    string memory symbol_,
    address anchorCurrency,
    uint256 anchorPrice,
    address inative,
    uint256 adjustmentNumerator,
    uint256 adjustmentDenominator,
    address[] memory currencies,
    uint256[] memory prices
) ERC20(name_, symbol_);
```

### deposit

Deposit and mint based on currency price


```solidity
function deposit(address[] memory currencies, uint256[] memory amounts)
    external
    payable
    nonReentrant
    returns (uint256 mintAmount);
```

### depositTokens


```solidity
function depositTokens(address[] memory currencies, uint256[] memory amounts, address caller, uint256 msgValue)
    internal;
```

### estimateDepositAmount


```solidity
function estimateDepositAmount(address[] memory currencies, uint256[] memory deposits)
    public
    view
    returns (uint256 amount);
```

### withdraw

Withdraw and burn tokens based on currency price


```solidity
function withdraw(address currency, uint256 amountIn) external nonReentrant returns (uint256 amountOut);
```

### estimateWithdrawAmount


```solidity
function estimateWithdrawAmount(address currency, uint256 amountIn) public view returns (uint256 amountOut);
```

### getCurrencyPrice

Returns the price of a currency


```solidity
function getCurrencyPrice(address currency) external view returns (uint256);
```

### getAnchorCurrency


```solidity
function getAnchorCurrency() external view returns (address);
```

### getAnchorPrice


```solidity
function getAnchorPrice() external view returns (uint256);
```

### getTokens


```solidity
function getTokens() external view returns (address[] memory);
```

### getTokenPrice


```solidity
function getTokenPrice(address token) external view returns (uint256);
```

### getTokenPrices


```solidity
function getTokenPrices(address[] memory treasuryTokens) external view returns (uint256[] memory);
```

