# DegenGambit
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/0fcf9b94218e26ecdc1d5cfff275d0c7e00950eb/src/DegenGambit.sol)

**Inherits:**
ERC20, ReentrancyGuard

This is the game contract for Degen's Gambit, a permissionless slot machine game.

Degen's Gambit comes with a streak mechanic. Players get an ERC20 GAMBIT token every time
they extend their streak. They can spend a GAMBIT token to spin with improved odds of winning.

*This ocntract depends on the ArbSys precompile that comes on Arbitrum Nitro chains to provide the current block number.
For more details: https://docs.arbitrum.io/build-decentralized-apps/arbitrum-vs-ethereum/block-numbers-and-time*


## State Variables
### BITS_30

```solidity
uint256 private constant BITS_30 = 0x3FFFFFFF;
```


### SECONDS_PER_DAY

```solidity
uint256 private constant SECONDS_PER_DAY = 60 * 60 * 24;
```


### DailyStreakReward
The GAMBIT reward for daily streaks.


```solidity
uint256 public constant DailyStreakReward = 1;
```


### WeeklyStreakReward
The GAMBIT reward for weekly streaks.


```solidity
uint256 public constant WeeklyStreakReward = 5;
```


### UnmodifiedLeftReel
Cumulative mass function for the UnmodifiedLeftReel


```solidity
uint256[19] public UnmodifiedLeftReel = [
    0 + 24970744,
    24970744 + 99882960,
    124853704 + 49941480,
    174795184 + 49941480,
    224736664 + 99882960,
    324619624 + 49941480,
    374561104 + 49941480,
    424502584 + 99882960,
    524385544 + 49941480,
    574327024 + 49941480,
    624268504 + 99882960,
    724151464 + 49941480,
    774092944 + 49941480,
    824034424 + 99882960,
    923917384 + 49941480,
    973858864 + 49941480,
    1023800344 + 24970740,
    1048771084 + 12485370,
    1061256454 + 12485370
];
```


### UnmodifiedCenterReel
Cumulative mass function for the UnmodifiedCenterReel


```solidity
uint256[19] public UnmodifiedCenterReel = [
    0 + 24970744,
    24970744 + 49941480,
    74912224 + 99882960,
    174795184 + 49941480,
    224736664 + 49941480,
    274678144 + 99882960,
    374561104 + 49941480,
    424502584 + 49941480,
    474444064 + 99882960,
    574327024 + 49941480,
    624268504 + 49941480,
    674209984 + 99882960,
    774092944 + 49941480,
    824034424 + 49941480,
    873975904 + 99882960,
    973858864 + 49941480,
    1023800344 + 12485370,
    1036285714 + 24970740,
    1061256454 + 12485370
];
```


### UnmodifiedRightReel
Cumulative mass function for the UnmodifiedCenterReel


```solidity
uint256[19] public UnmodifiedRightReel = [
    0 + 24970744,
    24970744 + 49941480,
    74912224 + 49941480,
    124853704 + 99882960,
    224736664 + 49941480,
    274678144 + 49941480,
    324619624 + 99882960,
    424502584 + 49941480,
    474444064 + 49941480,
    524385544 + 99882960,
    624268504 + 49941480,
    674209984 + 49941480,
    724151464 + 99882960,
    824034424 + 49941480,
    873975904 + 49941480,
    923917384 + 99882960,
    1023800344 + 12485370,
    1036285714 + 12485370,
    1048771084 + 24970740
];
```


### ImprovedLeftReel
Cumulative mass function for the ImprovedLeftReel


```solidity
uint256[19] public ImprovedLeftReel = [
    0 + 2526414,
    2526414 + 102068183,
    104594597 + 51034067,
    155628664 + 51034067,
    206662731 + 102068183,
    308730914 + 51034067,
    359764981 + 51034067,
    410799048 + 102068183,
    512867231 + 51034067,
    563901298 + 51034067,
    614935365 + 102068183,
    717003548 + 51034067,
    768037615 + 51034067,
    819071682 + 102068183,
    921139865 + 51034067,
    972173932 + 51034067,
    1023207999 + 25266913,
    1048474912 + 12633456,
    1061108368 + 12633456
];
```


### ImprovedCenterReel
Cumulative mass function for the ImprovedCenterReel


```solidity
uint256[19] public ImprovedCenterReel = [
    0 + 2526414,
    2526414 + 51034067,
    53560481 + 102068183,
    155628664 + 51034067,
    206662731 + 51034067,
    257696798 + 102068183,
    359764981 + 51034067,
    410799048 + 51034067,
    461833115 + 102068183,
    563901298 + 51034067,
    614935365 + 51034067,
    665969432 + 102068183,
    768037615 + 51034067,
    819071682 + 51034067,
    870105749 + 102068183,
    972173932 + 51034067,
    1023207999 + 12633456,
    1035841455 + 25266913,
    1061108368 + 12633456
];
```


### ImprovedRightReel
Cumulative mass function for the ImprovedCenterReel


```solidity
uint256[19] public ImprovedRightReel = [
    0 + 2526414,
    2526414 + 51034067,
    53560481 + 51034067,
    104594548 + 102068183,
    206662731 + 51034067,
    257696798 + 51034067,
    308730865 + 102068183,
    410799048 + 51034067,
    461833115 + 51034067,
    512867182 + 102068183,
    614935365 + 51034067,
    665969432 + 51034067,
    717003499 + 102068183,
    819071682 + 51034067,
    870105749 + 51034067,
    921139816 + 102068183,
    1023207999 + 12633456,
    1035841455 + 12633456,
    1048474911 + 25266913
];
```


### BlocksToAct
How many blocks a player has to act (respin/accept).


```solidity
uint256 public BlocksToAct;
```


### LastSpinBlock
The block number of the last spin/respin by each player.


```solidity
mapping(address => uint256) public LastSpinBlock;
```


### LastSpinBoosted
Whether or not the last spin for a given player is a boosted spin.


```solidity
mapping(address => bool) public LastSpinBoosted;
```


### CostToSpin
Cost (finest denomination of native token on the chain) to roll.


```solidity
uint256 public CostToSpin;
```


### CostToRespin
Cost (finest denomination of native token on the chain) to reroll.


```solidity
uint256 public CostToRespin;
```


### LastStreakDay
Day on which the last in-streak spin was made by a given player. This is for daily streaks.


```solidity
mapping(address => uint256) public LastStreakDay;
```


### LastStreakWeek
Week on which the last in-streak spin was made by a given player. This is for weekly streaks.


```solidity
mapping(address => uint256) public LastStreakWeek;
```


## Functions
### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceID) public pure returns (bool);
```

### constructor

In addition to the game mechanics, DegensGambit is also an ERC20 contract in which the ERC20
tokens represent bonus spins. The symbol for this contract is GAMBIT.


```solidity
constructor(uint256 blocksToAct, uint256 costToSpin, uint256 costToRespin) ERC20("Degen's Gambit", "GAMBIT");
```

### receive

Allows the contract to receive the native token on its blockchain.


```solidity
receive() external payable;
```

### decimals

The GAMBIT token (representing bonus rolls on the Degen's Gambit slot machine) has 0 decimals.


```solidity
function decimals() public pure override returns (uint8);
```

### _blockNumber


```solidity
function _blockNumber() internal view returns (uint256);
```

### _blockhash


```solidity
function _blockhash(uint256 number) internal view returns (bytes32);
```

### _enforceTick


```solidity
function _enforceTick(address degenerate) internal view;
```

### _enforceDeadline


```solidity
function _enforceDeadline(address degenerate) internal view;
```

### _entropy


```solidity
function _entropy(address degenerate) internal view virtual returns (uint256);
```

### sampleUnmodifiedLeftReel

sampleUnmodifiedLeftReel samples the outcome from UnmodifiedLeftReel specified by the given entropy


```solidity
function sampleUnmodifiedLeftReel(uint256 entropy) public view returns (uint256);
```

### sampleUnmodifiedCenterReel

sampleUnmodifiedCenterReel samples the outcome from UnmodifiedCenterReel specified by the given entropy


```solidity
function sampleUnmodifiedCenterReel(uint256 entropy) public view returns (uint256);
```

### sampleUnmodifiedRightReel

sampleUnmodifiedRightReel samples the outcome from UnmodifiedRightReel specified by the given entropy


```solidity
function sampleUnmodifiedRightReel(uint256 entropy) public view returns (uint256);
```

### sampleImprovedLeftReel

sampleImprovedLeftReel samples the outcome from ImprovedLeftReel specified by the given entropy


```solidity
function sampleImprovedLeftReel(uint256 entropy) public view returns (uint256);
```

### sampleImprovedCenterReel

sampleImprovedCenterReel samples the outcome from ImprovedCenterReel specified by the given entropy


```solidity
function sampleImprovedCenterReel(uint256 entropy) public view returns (uint256);
```

### sampleImprovedRightReel

sampleImprovedRightReel samples the outcome from ImprovedRightReel specified by the given entropy


```solidity
function sampleImprovedRightReel(uint256 entropy) public view returns (uint256);
```

### outcome

Returns the final symbols on the left, center, and right reels respectively for a spin with
the given entropy. The unused entropy is also returned for use by game clients.


```solidity
function outcome(uint256 entropy, bool boosted)
    public
    view
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`entropy`|`uint256`|The entropy created by the spin.|
|`boosted`|`bool`|Whether or not the spin was boosted.|


### payout

Payout function for symbol combinations.


```solidity
function payout(uint256 left, uint256 center, uint256 right) public view returns (uint256 result);
```

### prizes


```solidity
function prizes() external view returns (uint256[5] memory prizesAmount);
```

### _accept

This is the function a player calls to accept the outcome of a spin.

*This call can be delegated to a different account.*


```solidity
function _accept(address player)
    internal
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`player`|`address`|account claiming a prize.|


### accept

This is the function a player calls to accept the outcome of a spin.

*This call cannot be delegated to a different account.*


```solidity
function accept()
    external
    nonReentrant
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

### acceptFor

This is the function a player calls to accept the outcome of a spin.

*This call can be delegated to a different account.*


```solidity
function acceptFor(address player)
    external
    nonReentrant
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`player`|`address`|account claiming a prize.|


### spinCost


```solidity
function spinCost(address degenerate) public view returns (uint256);
```

### _spin

Spin the slot machine.

If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.

*This call can be delegated to a different account.*


```solidity
function _spin(address spinPlayer, address streakPlayer, bool boost, uint256 value) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spinPlayer`|`address`|account spin is for|
|`streakPlayer`|`address`|account streak reward is for|
|`boost`|`bool`|Whether or not the player is using a boost, msg.sender is paying the boost|
|`value`|`uint256`|value being sent to contract|


### spin

Spin the slot machine.

If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.

*Assumes msg.sender is player. This call cannot be delegated to a different account.*


```solidity
function spin(bool boost) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`boost`|`bool`|Whether or not the player is using a boost, msg.sender is paying the boost|


### spinFor

Spin the slot machine for the spinPlayer.

If the player sends more value than they absolutely need to, the contract simply accepts it into the pot.

*This call can be delegated to a different account.*


```solidity
function spinFor(address spinPlayer, address streakPlayer, bool boost) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spinPlayer`|`address`|account spin is for|
|`streakPlayer`|`address`|account streak reward is for|
|`boost`|`bool`|Whether or not the player is using a boost, msg.sender is paying the boost|


### inspectEntropy

inspectEntropy is a view method which allows clients to check the current entropy for a player given only their address.

*This is a convenience method so that clients don't have to calculate the entropy given the spin blockhash themselves. It
also enforces that blocks have ticked since the spin as well as the `BlocksToAct` deadline.*


```solidity
function inspectEntropy(address degenerate) external view returns (uint256);
```

### inspectOutcome

inspectOutcome is a view method which allows clients to check the outcome of a spin for a player given only their address.

This method allows clients to simulate the outcome of a spin in a single RPC call.

*The alternative to using this method would be to call `accept` (rather than submitting it as a transaction). This is simply a more
convenient and natural way to simulate the outcome of a spin, which also works on-chain.*


```solidity
function inspectOutcome(address degenerate)
    external
    view
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

### debuggerVersion

isDebuggable pure function that returns a string with debug version
if empty string non-debuggable


```solidity
function debuggerVersion() external pure virtual returns (string memory version);
```

## Events
### Spin
Fired when a player spins (and respins).


```solidity
event Spin(address indexed player, bool indexed bonus);
```

### Award
Fired when a player accepts the outcome of a roll.


```solidity
event Award(address indexed player, uint256 value);
```

### DailyStreak
Fired when a player continues a daily streak.


```solidity
event DailyStreak(address indexed player, uint256 day);
```

### WeeklyStreak
Fired when a player continues a weekly streak.


```solidity
event WeeklyStreak(address indexed player, uint256 week);
```

## Errors
### DeadlineExceeded
Signifies that the player is no longer able to act because too many blocks elapsed since their
last action.


```solidity
error DeadlineExceeded();
```

### WaitForTick
This error is raised to signify that the player needs to wait for at least one more block to elapse.


```solidity
error WaitForTick();
```

### InsufficientValue
Signifies that the player has not provided enough value to perform the action.


```solidity
error InsufficientValue();
```

### OutcomeOutOfBounds
Signifies that a reel outcome is out of bounds.


```solidity
error OutcomeOutOfBounds();
```

