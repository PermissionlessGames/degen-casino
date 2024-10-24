# TestableDegenGambit
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/b9fb495a9110c38147996f0bc6db8a1cd7c4ba0d/src/TestableDegenGambit.sol)

**Inherits:**
[DegenGambit](/src/DegenGambit.sol/contract.DegenGambit.md)


## State Variables
### EntropyForPlayer

```solidity
mapping(address => uint256) public EntropyForPlayer;
```


## Functions
### constructor


```solidity
constructor(uint256 blocksToAct, uint256 costToSpin, uint256 costToRespin)
    DegenGambit(blocksToAct, costToSpin, costToRespin);
```

### setEntropy


```solidity
function setEntropy(address player, uint256 entropy) public;
```

### _entropy


```solidity
function _entropy(address player) internal view override returns (uint256);
```

### mint


```solidity
function mint(address to, uint256 amount) public;
```

### reverseEntropy


```solidity
function reverseEntropy(uint256 left, uint256 center, uint256 right, address player) public;
```

### setDailyStreak


```solidity
function setDailyStreak(uint256 dailyStreak, address player) public;
```

### setWeeklyStreak


```solidity
function setWeeklyStreak(uint256 weeklyStreak, address player) public;
```

