# Syndication
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/12976e9fd5c84ac10effba9d0fe44362cdc76a38/src/syndication/Syndication.sol)

**Inherits:**
ReentrancyGuard


## State Variables
### degensGambit

```solidity
address public immutable degensGambit;
```


## Functions
### constructor


```solidity
constructor(address degenGambitGame);
```

### spinFor


```solidity
function spinFor(bool boost) external payable;
```

### acceptFor


```solidity
function acceptFor() external;
```

