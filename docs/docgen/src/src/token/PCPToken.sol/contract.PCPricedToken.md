# PCPricedToken
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/ef1d4f0f9ff01dcc397e9ddcaef29b2222eb408d/src/token/PCPToken.sol)

**Inherits:**
ERC20, ReentrancyGuard


## State Variables
### mintPricingData

```solidity
PCPricing.PricingData private mintPricingData;
```


### redeemPricingData

```solidity
PCPricing.PricingData private redeemPricingData;
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

### getTokens


```solidity
function getTokens() external view returns (address[] memory);
```

### getTokenPriceRatios


```solidity
function getTokenPriceRatios(address[] memory treasuryTokens)
    external
    view
    returns (uint256[] memory, uint256[] memory);
```

