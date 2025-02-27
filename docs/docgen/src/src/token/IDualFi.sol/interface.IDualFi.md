# IDualFi
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/ad02e177c5773bccbcd1369e63be4ea1e9311fae/src/token/IDualFi.sol)


## Functions
### deposit


```solidity
function deposit(uint256 value) external payable returns (uint256 amount);
```

### withdraw


```solidity
function withdraw(uint256 amountIn, bool wantNative) external returns (uint256 amount);
```

### swapNativeForToken


```solidity
function swapNativeForToken() external payable returns (uint256 amount);
```

### swapTokenForNative


```solidity
function swapTokenForNative(uint256 amountIn) external returns (uint256 amount);
```

### calculateDistributeAmount


```solidity
function calculateDistributeAmount(uint256 erc20Value, uint256 nativeValue) external view returns (uint256 amount);
```

### calculateWithdrawAmount


```solidity
function calculateWithdrawAmount(uint256 amountIn, bool wantNative) external view returns (uint256 amount);
```

### basis


```solidity
function basis() external view returns (uint256);
```

### trimValue


```solidity
function trimValue() external view returns (uint256);
```

### initialNativeRatio


```solidity
function initialNativeRatio() external view returns (uint256);
```

### initialERC20Ratio


```solidity
function initialERC20Ratio() external view returns (uint256);
```

### token


```solidity
function token() external view returns (address);
```

### dead


```solidity
function dead() external view returns (address);
```

