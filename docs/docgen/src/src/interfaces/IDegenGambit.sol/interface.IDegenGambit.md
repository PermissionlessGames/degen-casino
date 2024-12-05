# IDegenGambit
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/96c4f5bf386b90645fa24f94b3d190fc428bca09/src/interfaces/IDegenGambit.sol)


## Functions
### BlocksToAct


```solidity
function BlocksToAct() external view returns (uint256);
```

### CostToRespin


```solidity
function CostToRespin() external view returns (uint256);
```

### CostToSpin


```solidity
function CostToSpin() external view returns (uint256);
```

### DailyStreakReward


```solidity
function DailyStreakReward() external view returns (uint256);
```

### ImprovedCenterReel


```solidity
function ImprovedCenterReel(uint256) external view returns (uint256);
```

### ImprovedLeftReel


```solidity
function ImprovedLeftReel(uint256) external view returns (uint256);
```

### ImprovedRightReel


```solidity
function ImprovedRightReel(uint256) external view returns (uint256);
```

### LastSpinBlock


```solidity
function LastSpinBlock(address) external view returns (uint256);
```

### LastSpinBoosted


```solidity
function LastSpinBoosted(address) external view returns (bool);
```

### LastStreakDay


```solidity
function LastStreakDay(address) external view returns (uint256);
```

### LastStreakWeek


```solidity
function LastStreakWeek(address) external view returns (uint256);
```

### UnmodifiedCenterReel


```solidity
function UnmodifiedCenterReel(uint256) external view returns (uint256);
```

### UnmodifiedLeftReel


```solidity
function UnmodifiedLeftReel(uint256) external view returns (uint256);
```

### UnmodifiedRightReel


```solidity
function UnmodifiedRightReel(uint256) external view returns (uint256);
```

### WeeklyStreakReward


```solidity
function WeeklyStreakReward() external view returns (uint256);
```

### accept


```solidity
function accept()
    external
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

### acceptFor


```solidity
function acceptFor(address player)
    external
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint256);
```

### approve


```solidity
function approve(address spender, uint256 value) external returns (bool);
```

### balanceOf


```solidity
function balanceOf(address account) external view returns (uint256);
```

### decimals


```solidity
function decimals() external pure returns (uint8);
```

### hasPrize


```solidity
function hasPrize(address player) external view returns (bool toReceive);
```

### inspectEntropy


```solidity
function inspectEntropy(address degenerate) external view returns (uint256);
```

### inspectOutcome


```solidity
function inspectOutcome(address degenerate)
    external
    view
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

### name


```solidity
function name() external view returns (string memory);
```

### outcome


```solidity
function outcome(uint256 entropy, bool boosted)
    external
    view
    returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy);
```

### payout


```solidity
function payout(uint256 left, uint256 center, uint256 right) external view returns (uint256 result);
```

### prizes


```solidity
function prizes() external view returns (uint256[5] memory prizesAmount);
```

### sampleImprovedCenterReel


```solidity
function sampleImprovedCenterReel(uint256 entropy) external view returns (uint256);
```

### sampleImprovedLeftReel


```solidity
function sampleImprovedLeftReel(uint256 entropy) external view returns (uint256);
```

### sampleImprovedRightReel


```solidity
function sampleImprovedRightReel(uint256 entropy) external view returns (uint256);
```

### sampleUnmodifiedCenterReel


```solidity
function sampleUnmodifiedCenterReel(uint256 entropy) external view returns (uint256);
```

### sampleUnmodifiedLeftReel


```solidity
function sampleUnmodifiedLeftReel(uint256 entropy) external view returns (uint256);
```

### sampleUnmodifiedRightReel


```solidity
function sampleUnmodifiedRightReel(uint256 entropy) external view returns (uint256);
```

### spin


```solidity
function spin(bool boost) external;
```

### spinCost


```solidity
function spinCost(address degenerate) external view returns (uint256);
```

### spinFor


```solidity
function spinFor(address spinPlayer, address streakPlayer, bool boost) external;
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceID) external pure returns (bool);
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 value) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```

### version


```solidity
function version() external pure returns (string memory);
```

## Events
### Approval

```solidity
event Approval(address owner, address spender, uint256 value);
```

### Award

```solidity
event Award(address player, uint256 value);
```

### DailyStreak

```solidity
event DailyStreak(address player, uint256 day);
```

### Spin

```solidity
event Spin(address player, bool bonus);
```

### Transfer

```solidity
event Transfer(address from, address to, uint256 value);
```

### WeeklyStreak

```solidity
event WeeklyStreak(address player, uint256 week);
```

## Errors
### DeadlineExceeded

```solidity
error DeadlineExceeded();
```

### ERC20InsufficientAllowance

```solidity
error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
```

### ERC20InsufficientBalance

```solidity
error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
```

### ERC20InvalidApprover

```solidity
error ERC20InvalidApprover(address approver);
```

### ERC20InvalidReceiver

```solidity
error ERC20InvalidReceiver(address receiver);
```

### ERC20InvalidSender

```solidity
error ERC20InvalidSender(address sender);
```

### ERC20InvalidSpender

```solidity
error ERC20InvalidSpender(address spender);
```

### InsufficientValue

```solidity
error InsufficientValue();
```

### OutcomeOutOfBounds

```solidity
error OutcomeOutOfBounds();
```

### ReentrancyGuardReentrantCall

```solidity
error ReentrancyGuardReentrantCall();
```

### WaitForTick

```solidity
error WaitForTick();
```

