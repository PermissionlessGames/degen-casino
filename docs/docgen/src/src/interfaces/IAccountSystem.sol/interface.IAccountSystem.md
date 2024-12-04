# IAccountSystem
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/747a9f879e52c48fe525c83a0a51a637e87ccd6e/src/interfaces/IAccountSystem.sol)


## Functions
### accountVersion


```solidity
function accountVersion() external view returns (string memory);
```

### accounts


```solidity
function accounts(address) external view returns (address);
```

### calculateAccountAddress


```solidity
function calculateAccountAddress(address player) external view returns (address result);
```

### createAccount


```solidity
function createAccount(address player) external returns (address, bool);
```

### systemVersion


```solidity
function systemVersion() external view returns (string memory);
```

## Events
### AccountCreated

```solidity
event AccountCreated(address account, address player, string accountVersion);
```

### AccountSystemCreated

```solidity
event AccountSystemCreated(string systemVersion, string accountVersion);
```

