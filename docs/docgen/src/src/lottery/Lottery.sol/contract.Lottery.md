# Lottery
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/760b4fc276a589a76aa0e7708831424a0d0591e7/src/lottery/Lottery.sol)

**Author:**
Your Name

Players can check if a ticket has matching numbers and claim prizes.

*Uses an external Bitmask library for encoding, decoding & number matching.*


## State Variables
### currentLotteryId

```solidity
uint256 public currentLotteryId;
```


### lotteries

```solidity
mapping(uint256 => LotteryGame) public lotteries;
```


### playerTickets

```solidity
mapping(address => mapping(uint256 => uint256[])) public playerTickets;
```


## Functions
### lotteryActive


```solidity
modifier lotteryActive(uint256 lotteryId);
```

### hasMatching

Checks if a specific ticket has matching numbers.

*Takes `lotteryId`, `playerAddress`, and `ticketId` to validate winnings.*


```solidity
function hasMatching(uint256 lotteryId, address player, uint256 playerTicketId)
    public
    view
    returns (uint256 matchingCount);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`matchingCount`|`uint256`|Number of matching numbers.|


### setClaimedPrize

Internal function to mark a ticket as claimed.

*Ensures the same ticket cannot be claimed multiple times.*


```solidity
function setClaimedPrize(uint256 lotteryId, address player, uint256 ticketId) internal;
```

### getPlayerTickets

Returns the player's ticket selections for a specific lottery.

*Uses `Bitmask.decode()` to return readable number selections.*


```solidity
function getPlayerTickets(address player, uint256 lotteryId) public view returns (uint256[][] memory);
```

### processTicketPurchase

Internal function that processes ticket purchases.

*Called by `buyTicket()` and `buyMultipleTickets()` to reduce redundant code.*


```solidity
function processTicketPurchase(uint256 lotteryId, uint256[] memory numbers, address player)
    internal
    returns (bool added);
```

### getWinningNumbers

Returns the winning numbers for a specific lottery as an array.

*Uses `Bitmask.decode()` to convert the stored bitmask into a number array.*


```solidity
function getWinningNumbers(uint256 lotteryId) public view returns (uint256[] memory);
```

### getPlayersForNumbers

Returns the players who picked a given combination of numbers in a lottery.

*The input is a decoded array of numbers instead of a raw bitmask.*


```solidity
function getPlayersForNumbers(uint256 lotteryId, uint256[] memory numbers)
    public
    view
    virtual
    returns (address[] memory);
```

### createLottery

Internal function to create a lottery.

*Must be called within derived contracts or automated systems.*


```solidity
function createLottery(uint256 maxNumber, uint256 numbersToPick) internal;
```

### setWinningNumbers

Internal function to set the winning numbers.

*Must be called within derived contracts or automated systems.*


```solidity
function setWinningNumbers(uint256 lotteryId, uint256[] memory numbers) internal;
```

## Events
### LotteryCreated

```solidity
event LotteryCreated(uint256 indexed lotteryId, uint256 maxNumber, uint256 numbersToPick);
```

### TicketPurchased

```solidity
event TicketPurchased(address indexed player, uint256 indexed lotteryId, uint256 numberBitmask);
```

### MultipleTicketsPurchased

```solidity
event MultipleTicketsPurchased(address indexed player, uint256 indexed lotteryId, uint256 ticketCount);
```

### WinningNumbersSet

```solidity
event WinningNumbersSet(uint256 indexed lotteryId, uint256 numberBitmask);
```

### PrizeClaimed

```solidity
event PrizeClaimed(address indexed player, uint256 indexed lotteryId, uint256 ticketId);
```

## Structs
### LotteryGame

```solidity
struct LotteryGame {
    uint256 lotteryId;
    uint256 maxNumber;
    uint256 numbersToPick;
    uint256 winningBitmask;
    bool isActive;
    mapping(uint256 => address[]) ticketOwners;
    mapping(bytes32 => bool) claimedTickets;
}
```

