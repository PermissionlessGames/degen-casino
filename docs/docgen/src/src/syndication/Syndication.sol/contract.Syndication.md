# Syndication
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/22309111ceb3a063b3a75ee9357ecc503a2827a1/src/syndication/Syndication.sol)

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

