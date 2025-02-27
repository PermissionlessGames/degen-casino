# DualFi
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/4d72b07d1238d80629235817f4b6137866443bea/src/token/DualFi.sol)

**Inherits:**
ERC20, ReentrancyGuard


## State Variables
### token

```solidity
address public immutable token;
```


### basis

```solidity
uint256 public immutable basis;
```


### dead

```solidity
address public dead = address(0xdead);
```


### initialNativeRatio

```solidity
uint256 public immutable initialNativeRatio;
```


### initialERC20Ratio

```solidity
uint256 public immutable initialERC20Ratio;
```


### trimValue

```solidity
uint256 public immutable trimValue;
```


## Functions
### constructor


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address tokenA,
    uint256 initialAmount0Token,
    uint256 initialAmountNative,
    uint256 _basis,
    uint256 _trimValue
) ERC20(_name, _symbol);
```

### deposit


```solidity
function deposit(uint256 value) external payable nonReentrant returns (uint256 amount);
```

### calculateDistributeAmount


```solidity
function calculateDistributeAmount(uint256 erc20Value, uint256 nativeValue) public view returns (uint256 amount);
```

### withdraw


```solidity
function withdraw(uint256 amountIn, bool wantNative) external nonReentrant returns (uint256 amount);
```

### calculateWithdrawAmount


```solidity
function calculateWithdrawAmount(uint256 amountIn, bool wantNative) public view returns (uint256 amount);
```

### _trackTrim


```solidity
function _trackTrim() internal;
```

### internalSwap


```solidity
function internalSwap(uint256 amountIn, bool wantNative) internal returns (uint256 amount);
```

### swapNativeForToken


```solidity
function swapNativeForToken() external payable nonReentrant returns (uint256 amount);
```

### swapTokenForNative


```solidity
function swapTokenForNative(uint256 amountIn) external nonReentrant returns (uint256 amount);
```

### __mint


```solidity
function __mint(address to, uint256 amount) internal;
```

