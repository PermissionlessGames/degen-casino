# TestableDegenGambit
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/6045da79bcc780d5296b9e30abdb6b97559ac8ac/src/testable/TestableDegenGambit.sol)

**Inherits:**
[DegenGambit](/src/DegenGambit.sol/contract.DegenGambit.md)


## State Variables
### EntropyForPlayer

```solidity
mapping(address => uint256) public EntropyForPlayer;
```


### EntropyIsHash

```solidity
bool public EntropyIsHash;
```


## Functions
### constructor


```solidity
constructor(uint256 blocksToAct, uint256 costToSpin, uint256 costToRespin)
    DegenGambit(blocksToAct, costToSpin, costToRespin);
```

### setEntropySource


```solidity
function setEntropySource(bool isFromHash) external;
```

### setEntropy


```solidity
function setEntropy(address player, uint256 entropy) public;
```

### _entropy


```solidity
function _entropy(address player) internal view override returns (uint256);
```

### mintGambit


```solidity
function mintGambit(address to, uint256 amount) public;
```

### setDailyStreak


```solidity
function setDailyStreak(uint256 dailyStreak, address player) public;
```

### setWeeklyStreak


```solidity
function setWeeklyStreak(uint256 weeklyStreak, address player) public;
```

### version


```solidity
function version() external pure override returns (string memory);
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
function setEntropyFromOutcomes(uint256 left, uint256 center, uint256 right, address player, bool boost)
    public
    returns (uint256 entropy);
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

### setBlocksToAct


```solidity
function setBlocksToAct(uint256 newBlocksToAct) external;
```

### setLastSpinBoosted


```solidity
function setLastSpinBoosted(address player, bool boost) external;
```

### setLastSpinBlock


```solidity
function setLastSpinBlock(address player, uint256 blockNumber) external;
```

### setCostToSpin


```solidity
function setCostToSpin(uint256 newCostToSpin) external;
```

### setCostToRespin


```solidity
function setCostToRespin(uint256 newCostToRespin) external;
```

