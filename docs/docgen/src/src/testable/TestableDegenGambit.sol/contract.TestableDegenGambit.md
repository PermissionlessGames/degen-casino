# TestableDegenGambit
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/1b23ad7777915abbfdb2a1ab19a9b4469f7ebb89/src/testable/TestableDegenGambit.sol)

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

### setDailyStreak


```solidity
function setDailyStreak(uint256 dailyStreak, address player) public;
```

### setWeeklyStreak


```solidity
function setWeeklyStreak(uint256 weeklyStreak, address player) public;
```

### generateEntropyForUnmodifiedReelOutcome


```solidity
function generateEntropyForUnmodifiedReelOutcome(uint256 leftOutcome, uint256 centerOutcome, uint256 rightOutcome)
    public
    view
    returns (uint256);
```

### setEntropyFromOutcomes


```solidity
function setEntropyFromOutcomes(uint256 left, uint256 center, uint256 right, address player, bool boost) public;
```

### generateEntropyForImprovedReelOutcome


```solidity
function generateEntropyForImprovedReelOutcome(uint256 leftOutcome, uint256 centerOutcome, uint256 rightOutcome)
    public
    view
    returns (uint256);
```

### getSampleForOutcome


```solidity
function getSampleForOutcome(uint256 outcome, uint256[19] storage reel) internal view returns (uint256);
```

