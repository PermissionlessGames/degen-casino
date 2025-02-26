# RecurringClaimsDistribution
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/a132d2a038139d2d91746b28f555d8474f835d18/src/distribution/RecurringClaimsDistribution.sol)

**Inherits:**
ReentrancyGuard


## State Variables
### rounds

```solidity
mapping(uint256 => DistributionRound) public rounds;
```


### lastClaimed

```solidity
mapping(uint256 => mapping(address => uint256)) public lastClaimed;
```


### amountClaimed

```solidity
mapping(uint256 => mapping(address => uint256)) public amountClaimed;
```


### nextRoundId

```solidity
uint256 public nextRoundId;
```


## Functions
### roundActive


```solidity
modifier roundActive(uint256 roundId);
```

### startNewRound

Creates a new distribution round with a fixed token supply and recipient list.


```solidity
function startNewRound(
    address token,
    address[] calldata recipients,
    uint256 minClaimInterval,
    uint256 totalTokens,
    uint256 numberOfClaimsRequired
) external payable nonReentrant returns (uint256 roundId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The ERC20 token address (zero address for native asset).|
|`recipients`|`address[]`|The list of recipients for this round (can include duplicates).|
|`minClaimInterval`|`uint256`|Minimum time between claims for this round.|
|`totalTokens`|`uint256`|The fixed number of tokens to distribute.|
|`numberOfClaimsRequired`|`uint256`||


### _endRoundIfNeeded

Automatically ends a round if tokens are fully distributed.


```solidity
function _endRoundIfNeeded(uint256 roundId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The round ID to check.|


### claimTokens

Allows individual recipients to claim their allocated tokens or allows others to do it for them.


```solidity
function claimTokens(uint256 roundId, address recipeint) external nonReentrant roundActive(roundId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The round from which to claim tokens.|
|`recipeint`|`address`|The individual who is claiming|


### getRecipients

Returns the recipients of a given round.


```solidity
function getRecipients(uint256 roundId) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The round ID.|


### getRecipientEntries

Returns the number of times a recipient was included in a round.


```solidity
function getRecipientEntries(uint256 roundId, address recipient) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The round ID.|
|`recipient`|`address`|The recipient's address.|


### getAmountClaimed

Returns the amount claimed by a recipient in a round.


```solidity
function getAmountClaimed(uint256 roundId, address recipient) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The round ID.|
|`recipient`|`address`|The recipient's address.|


## Events
### RoundStarted

```solidity
event RoundStarted(
    uint256 indexed roundId, address indexed creator, address token, uint256 totalTokens, uint256 minClaimInterval
);
```

### RoundEnded

```solidity
event RoundEnded(uint256 indexed roundId);
```

### TokensClaimed

```solidity
event TokensClaimed(uint256 indexed roundId, address indexed recipient, uint256 amount, bool isERC20);
```

### ClaimIntervalUpdated

```solidity
event ClaimIntervalUpdated(uint256 indexed roundId, uint256 interval);
```

## Structs
### DistributionRound

```solidity
struct DistributionRound {
    address token;
    uint256 numberOfClaimsRequired;
    uint256 totalTokens;
    uint256 minClaimInterval;
    uint256 remainingTokens;
    uint256 totalPerEntryPerClaim;
    bool isActive;
    address[] uniqueRecipients;
    mapping(address => uint256) recipientEntries;
    uint256 totalEntries;
}
```

