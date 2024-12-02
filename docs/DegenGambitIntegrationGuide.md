# The *Degen's Gambit* integration guide

This document describes the player flows on the `DegenGambit` smart contract and breaks down how each
flow can be implemented in terms of the smart contract methods involved. It is meant for people
programming *Degen's Gambit* game clients.

Interacting with a `DegenGambit` smart contract:
- Use the [`DegenGambit` ABI](./abis/DegenGambit.abi.json) if you want to interact with a game contract from outside the blockchain.
- Use the [`IDegenGambit` interface](./interfaces/IDegenGambit.sol) if you want to interact with a game contract from another contract.

Flows:
1. [The Pot](#the-pot)
1. [Spinning the slot machine](#spinning-the-slot-machine)
1. [Boosting spins with GAMBIT](#boosting-spins-with-gambit)
1. [Daily and weekly streaks](#daily-and-weekly-streaks)

## The Pot

*Degen's Gambit* is a permissionless slot machine. This means that there is no organization or company charging a rake every time a player spins
the reels. Instead, any money the player loses goes into a communal pot which represents the total *Degen's Gambit* prize pool. Any money that players win
by playing *Degen's Gambit* comes from this pot.

The pot for a *Degen's Gambit* smart contract is denominated in the native token of the blockchain it exists on. To check the current size of the pot, simply
read the balance of the *Degen's Gambit* smart contract.

For example, if you are interested in the size of the pot for the *Degen's Gambit* contract deployed at
[`0xCE75cd656b2C4114aD9fb3c82E188658E6fc6a4C`](https://testnet.game7.io/address/0xCE75cd656b2C4114aD9fb3c82E188658E6fc6a4C?tab=contract)
on the Game7 testnet, you could make an RPC call as follows:

```solidity
	// Selector: 11cceaf6
	function prizes() external view returns (uint256[] memory prizesAmount, uint256[] memory typeOfPrize);
```

The return values, in order:
1. Index 0: prize for spinning matching minor left and right, with a different minor symbol
2. Index 1: prize for spinning all matching minor symbols
3. Index 2: prize for spinning matching minor symbol left and right, with a major symbol center
4. Index 3: prize for spinning matching major symbol left and right, with a different major symbol center
5. Index 4: prize for spinning 3 different major symbols
6. index 5: prize for spinning all matching major symbol

The return values for `typeOfPrize`
1. 1 `native Token`
2. 20 `Gambit Token`


The `"result"` key is the hexadecimal representation of the balance. In this case, the pot size is `0x3a99e = 240030`.

If you are using `web3.js`, `web3.py`, `ethers.js`, or a similar client library, you will not need to form this request yourself, nor will you need to
decode the result. Please consult the relevant library documentation to see how to perform a balance check.


## Spinning the slot machine

*Degen's Gambit* exposes [`spin` method](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spin) and [`spinFor` method](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spinFor) which you can call to spin the reels on the slot machine.

These methods have the following signature:

```solidity
	// Selector: 6499572f
	function spin(bool boost) external payable;
	// Selector: 2b10c68b
	function spinFor(address spinPlayer, address streakPlayer, bool boost) external payable;
```

Each spin/spinFor costs the player/caller native tokens to execute. If `boost = true`, the spin will be boosted. This is something we cover in greater detail in the next section,
[Boosting spins with GAMBIT](#boosting-spins-with-gambit). The basic mechanics of spinning (and respinning) work the same way whether `boost` is `true` or `false`.
This section elaborates on these mechanics.

When a caller uses spinFor to spin for a player. Parameters `spinPlayer = Receives Payout, streakPlayer = Receives Gambit` are used instead of assuming caller as player.

When a player spins, the entropy used to determine the outcome of their spin is determined as a combination of the block hash of the block in which their spin
transaction was included on the blockchain together with their Ethereum account address.

You can check the block at which the player last spun using the [`LastSpinBlock`](docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#lastspinblock) mapping
on the game contract.

This mapping can be accessed as a view method using either the [`IDegenGambit` interface](./interfaces/IDegenGambit.sol) on-chain or the [ABI](./abis/DegenGambit.abi.json) off-chain.

Once at least one block has passed, subject to a block deadline (described below), you can view the outcome available to the player by calling the
[`inspectOutcome`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#inspectoutcome) method on the contract:

```solidity
	// Selector: eca8b788
	function inspectOutcome(address degenerate) external view returns (uint256 left, uint256 center, uint256 right, uint256 remainingEntropy, uint256 prize);
```

The return values specify, in order:
1. The final symbol on the left reel.
1. The final symbol on the center reel.
1. The final symbol on the right reel.
1. A 166-bit integer representing the entropy unused by the game. This entropy is statistically independent from the entropy used to determine the
symbols that the reels come to rest on. Clients are free to use this entropy in any manner they wish to. Using this entropy allows game clients to
produce effects that are invariant under distinct sessions.
1. The amount of native tokens that the player would win by accepting the outcome.

The `inspectOutcome` call will fail if either a block has not ticked since the player's last spin or if the block deadline has passed after the player's last spin.

When a *Degen's Gambit* smart contract is deployed, it is configured with a [`BlocksToAct`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#blockstoact) parameter:

```solidity
uint256 public BlocksToAct;
```

Being a public variable, you can access this parameter by calling `BlocksToAct` as a view method (with no arguments) on the
[contract interface](./interfaces/IDegenGambit.sol):

```solidity
	// Selector: be59cce3
	function BlocksToAct() external view returns (uint256);
```

After a player spins, they have `BlocksToAct` blocks to either:
1. Accept the outcome of their spin by submitting an [`accept` transaction](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#accept) or [`acceptFor` transaction](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#acceptFor).
1. *Not* accept the outcome of their spin and respin at a discounted cost by submitting a
[`spin` transaction](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spin).
1. Do nothing.

The accept methods have the following signature:

```solidity
function accept() external;
function acceptFor(address player) external;
```

A client can inspect the status of this deadline for a given `player` by checking if:

```solidity
block.number <= IDegenGambit(game).LastSpinBlock(player) + IDegenGambit(game).BlocksToAct();
```

This check can be made from off the blockchain by polling the current block number from a JSONRPC API to that chain and using that in place of
`block.number` above. Off-chain clients will need to poll for the current block number if they want to stay up-to-date regarding the block deadline
and they are using the JSONRPC API. Clients that can establish websocket connections with an RPC node can also send an
[`eth_subscribe` message for `newHeads`](https://www.quicknode.com/docs/ethereum/eth_subscribe) to receive websocket messages every time a block is produced.

When a *Degen's Gambit* game contract is deployed, it is also configured with the full spin cost and the discounted spin cost for respins made before the
`BlocksToAct` deadline expires after a spin. These are defined as follows on the [`DegenGambit`](../src/DegenGambit.sol):

```solidity
    /// Cost (finest denomination of native token on the chain) to roll.
    uint256 public CostToSpin;

    /// Cost (finest denomination of native token on the chain) to reroll.
    uint256 public CostToRespin;
```

And can be called as view methods:

```solidity
	// Selector: e4a2e5b3
	function CostToRespin() external view returns (uint256);
	// Selector: ab6282c8
	function CostToSpin() external view returns (uint256);
```

To understand a player's cost for the next spin, one would first have to calculate when the player made their last spin, and whether they accepted the outcome of
that spin or not. If the player made their last spin the past `BlocksToAct` blocks but did not `accept` the outcome of that spin, they would be eligible to respin at
the `CostToRespin` cost. Otherwise, their next `spin` would cost `CostToSpin`.

The `DegenGambit` contract offers the [`spinCost` convenience method](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spincost),
which automatically does these calculations and tells clients how much the players next spin is expected to cost:

```solidity
	// Selector: 6f785558
	function spinCost(address degenerate) external view returns (uint256);
```

### Suggested spin implementation using JSONRPC API

This is one way that game clients could implement the spin flow for players:

1. Call [`spinCost`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spincost) and communicate to the player how much their next spin would cost.
2. If the player has a positive GAMBIT balance, give them the option of making a boosted spin. This is covered in detail in the
[*Boosting spins with GAMBIT*](#boosting-spins-with-gambit) section below.
3. Once the player makes the spin, start polling the chain's block number.
4. Once the spin transaction has been included in the blockchain, call [`inspectOutcome`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#inspectoutcome) to show the player the symbols on the reels, and what they would receive in prizes if they accepted that outcome.
5. Allow the players to either respin (go back to the beginning of this flow) or `accept` the outcome until `BlocksToAct` blocks have passed since they made their spin.
6. If `BlocksToAct` blocks pass after the player's last spin, go back to the beginning of this workflow.

## Boosting spins with GAMBIT

The `DegenGambit` token, in addition to being a slot machine, is also an ERC20 contract. Its tokens are called `GAMBIT` tokens, and they can be used by players
to improve their odds of getting a winning outcome on a spin.

Each boost costs a single `GAMBIT` token and a player can indicate that they would like to use a `GAMBIT` token to boost their spin by setting the `boost` argument to `true` on the [`spin` method](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spin):

```solidity
	// Selector: 6499572f
	function spin(bool boost) external payable;
	// Selector: 2b10c68b
	function spinFor(address spinPlayer, address streakPlayer, bool boost) external payable;
```

If a player makes a boosted spin, a single `GAMBIT` token is burned from their account.

(Note: The `DegenGambit` contract does not need `ERC20` approval from the player for this as it is itself the ERC20 contract on which the token is being burned.)

There are two ways for players to acquire GAMBIT tokens:
1. Earn `GAMBIT` from the game by continuing a daily or weekly streak. The [Daily and weekly streaks](#daily-and-weekly-streaks) below discusses this mechanic.
2. Acquire `GAMBIT` on the open market. We do not cover this flow in this integration guide - there is a lot of diversity in how players could purchase or acquire
`GAMBIT` from others (DEX purchases, loans, prize sharing agreements, etc.).

The only way that `GAMBIT` is actually produced in the economy is by players coming in and spinning the slot machine on consecutive days and consecutive weeks.

## Daily and weekly streaks

Daily and weekly streaks are extended automatically when a player spins. A player needs do nothing *but* spin in order to start or extend a streak.

This makes it really easy for players to continue streaks, but it does make it more difficult for game clients to understand that a streak has been extended. In
this section, we will describe two ways for game clients to communicate the state of their streaks back to the player.

First, some background on streaks. *Degen's Gambit* has two kinds of streaks:
1. Daily streaks: If a player spins the slot machine on day `N` and then again on day `N+1`, their first spin on day `N+1` earns them some `GAMBIT` tokens.
2. Weekly streaks: If a player spins the slot machine on week `M` and then again on week `M+1`, their first spin on week `M+1` earns them some `GAMBIT` tokens.

The `GAMBIT` rewards for extending daily and weekly streaks are defined by:

```solidity
	// Selector: df43230f
	function DailyStreakReward() external view returns (uint256);
```

and

```solidity
	// Selector: 97c87050
	function WeeklyStreakReward() external view returns (uint256);
```

respectively. Each method specifies the number of `GAMBIT` tokens a player will earn by extending a daily or weekly streak.

The contract defines a day as all the Unix timestamps with the same quotient when divided by `60*60*24 = 86400`. It defines a week as all the Unix timestamps with
the same quotient when divided by `60*60*24*7 = 604800`.

If a spin starts or extends a daily streak, it emits the following event:

```solidity
	event DailyStreak(address player, uint256 day);
```

If a spin starts or extends a weekly streak, it emits the following event:

```solidity
	event WeeklyStreak(address player, uint256 week);
```

Therefore, one way for clients to detect if a streak has been started or extended is to inspect spin transactions for either of these events, or to listen for
these events directly on a node. This kind of indexing does come with some overhead, although the World Builder team does plan to expose a public API that exposes these
event emissions to game clients for the slot machines deployed to the Game7 testnet and mainnet.

A more simple way for game clients to detect when a player begins a streak or extends it is to monitor changes to the following state on the `DegenGambit` contract:

```solidity
	// Selector: fcb13e26
	function LastStreakDay(address ) external view returns (uint256);
	// Selector: cf71aae2
	function CurrentDailyStreakLength(address ) external view returns (uint256);
	// Selector: 21c58fba
	function LastStreakWeek(address ) external view returns (uint256);
	// Selector: 215a57c1
	function CurrentWeeklyStreakLength(address ) external view returns (uint256);
```

In reality, these are public mappings on [`DegenGambit`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#laststreakday). Every time a player begins or continues a streak, a client can use the change in `LastStreakDay` or `LastStreakWeek` to determine what happened.

For daily streaks:
1. If `LastStreakDay` did not change on a `spin`, then there has been no change to the player's streaks.
2. If `LastStreakDay` increased by 1, the player has extended a streak and received `DailyStreakReward()` `GAMBIT` tokens.
3. If `LastStreakDay` increased by more than 1, the player has started a new streak and has not received any `GAMBIT` reward. They will receive `DailyStreakReward()` `GAMBIT` tokens if they `spin` again tomorrow and their `CurrentDailyStreakLength` will increase by 1. 

For weekly streaks:
1. If `LastStreakWeek` did not change on a `spin`, then there has been no change to the player's streaks.
2. If `LastStreakWeek` increased by 1, the player has extended a streak and received `WeeklyStreakReward()` `GAMBIT` tokens.
3. If `LastStreakWeek` increased by more than 1, the player has started a new streak and has not received any `GAMBIT` reward. They will receive `WeeklyStreakReward()` `GAMBIT` tokens if they `spin` again next weekand their `CurrentWeeklyStreakLength` will increase by 1.

## Debugging with TestableDegenGambit

Interacting with a `TestableDegenGambit` smart contract:
- Use the [`TestableDegenGambit` ABI](./abis/testable/TestableDegenGambit.abi.json) if you want to interact with a game contract from outside the blockchain.

The `TestableDegenGambit` debugging uses a testable contract to improve and test functions and condintions on and off chain.

Current `TestableDegenGambit` launched [`0x02BF55866d7F2226D4998dfC8D8c4D48B87358c1`](https://testnet.game7.io/address/0x02BF55866d7F2226D4998dfC8D8c4D48B87358c1?tab=contract)

Developers can use the debugger to check for the version of the testable smart contract. This allows front-end developers to easily test on-chain events that will trigger on-screen events i.e. reels spinning, jackpots hit etc.. This allows for front-end development to determine between a testable and non-testable based on contract versions string [`version` method](./docgen/src/src/TestableDegenGambit.sol/contract.TestableDegenGambit.md#version):

```solidity
	function version() external pure virtual returns (string memory);
```

Testing specfic outcomes on `TestableDegenGambit` make sure [`EntropyIsHash` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#EntropyIsHash) is set to `false` with [`setEntropySource` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setEntropySource) if `true` pulls hash from `ArbSys`. Then use [`setEntropyFromOutcomes` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setEntropyFromOutcomes) to set the desired outcome:


```solidity
	bool public EntropyIsHash
	function setEntropySource(bool isFromHash) external;
	function setEntropyFromOutcomes(uint256 left, uint256 center, uint256 right, address player, bool boost) public;
```

Testing daily and weekly streaks using [`setDailyStreak` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setDailyStreak), [`setDailyStreakLength` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setDailyStreakLength), [`setWeekltStreak` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setWeeklyStreak), and [`setWeeklyStreakLength` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setWeeklyStreakLength)


```solidity
function setDailyStreak(uint256 dailyStreak, address player) public;
function setDailyStreakLength(uint256 dailyStreakLength, address player) public;

function setWeeklyStreak(uint256 weeklyStreak, address player) public;
function setWeeklyStreakLength(uint256 weeklyStreakLength, address player) public;
```

Testing spin's LastSpinBoosted and LastSpinBlock streaks using [`setLastSpinBoosted` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setLastSpinBoosted) and [`setLastSpinBlock` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setLastSpinBlock). Setting LastSpinBlock can activate a spin without calling spin or spinFor and setting LastSpinBoosted allows for quick reponses(without events emit) and allows for accept and acceptFor to be called.

```solidity
    function setLastSpinBoosted(address player, bool boost) external;

    function setLastSpinBlock(address player, uint256 blockNumber) external;
```

Testing Gambit fixed variables CostToSpin, CostToRespin, BlocksToAct using [`setBlocksToAct` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setBlocksToAct), [`setCostToSpin` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setCostToSpin), [`setCostToRespin` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#setCostToRespin). Allows for adjusting constructor parameters during debugging.

```solidity
    function setBlocksToAct(uint256 newBlocksToAct) external;

    function setCostToSpin(uint256 newCostToSpin) external;

    function setCostToRespin(uint256 newCostToRespin) external;
```

Testing Gambit transfers for boosted spins use [`mintGambit` method](./docgen/src/src/testable/TestableDegenGambit.sol/contract.TestableDegenGambit.md#mintGambit). This will mint gambit for the desinated address. 

```solidity
	function mintGambit(address to, uint256 amount) public;
```