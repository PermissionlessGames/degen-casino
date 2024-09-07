# The *Degen's Gambit* integration guide

This document describes the player flows on the `DegenGambit` smart contract and breaks down how each
flow can be implemented in terms of the smart contract methods involved. It is meant for people
programming *Degen's Gambit* game clients.

Interactin with a `DegenGambit` smart contract:
- Use the [`DegenGambit` ABI](./abis/DegenGambit.abi.json) if you want to interact with a game contract from outside the blockchain.
- Use the [`IDegenGambit` interface](./interfaces/IDegenGambit.sol) if you want to interact with a game contract from another contract.

Flows:
1. [The Pot](#the-pot)
1. [Spinning the slot machine](#spinning-the-slot-machine)
1. Boosting spins with GAMBIT
1. Earning GAMBIT through daily and weekly streaks
1. Simulating outcomes

## The Pot

*Degen's Gambit* is a permissionless slot machine. This means that there is no organization or company charging a rake every time a player spins
the reels. Instead, any money the player loses goes into a commmunal pot which represents the total *Degen's Gambit* prize pool. Any money that players win
by playing *Degen's Gambit* comes from this pot.

The pot for a *Degen's Gambit* smart contract is denominated in the native token of the blockchain it exists on. To check the current size of the pot, simply
read the balance of the *Degen's Gambit* smart contract.

For example, if you are interested in the size of the pot for the *Degen's Gambit* contract deployed at
[`0x3f2F2A8C37f200802f3468507dE8AFa25777b4b9`](https://explorer-game7-testnet-0ilneybprf.t.conduit.xyz/address/0x3f2F2A8C37f200802f3468507dE8AFa25777b4b9?tab=contract)
on the Game7 testnet, you could make an RPC call as follows:

```bash
curl "https://rpc-game7-testnet-0ilneybprf.t.conduit.xyz" \
    -H "Content-Type: application/json"  \
    -X POST  \
    -d '{"id": 1, "jsonrpc": "2.0", "method": "eth_getBalance", "params": ["0x3f2F2A8C37f200802f3468507dE8AFa25777b4b9", "latest"]}'
```

This will return a response of the following form:

```json
{"jsonrpc":"2.0","result":"0x3a99e","id":1}
```

The `"result"` key is the hexadecimal representation of the balance. In this case, the pot size is `0x3a99e = 240030`.

If you are using `web3.js`, `web3.py`, `ethers.js`, or a similar client library, you will not need to form this request yourself, nor will you need to
decode the result. Please consult the relevant library documentation to see how to perform a balance check.


## Spinning the slot machine

*Degen's Gambit* exposes a [`spin` method](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spin) which you can call to spin the reels on the slot machine.

This method has the following signature:

```solidity
function spin(bool boost) external payable;
```

Each spin costs the player native tokens to execute. If `boost = true`, the spin will be boosted. This is something we cover in greater detail in the next section,
[Boosting spins with GAMBIT](#boosting-spins-with-gambit). The basic mechanics of spinning (and respinning) work the same way whether `boost` is `true` or `false`.
This section elaborates on these mechanics.

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
1. Accept the outcome of their spin by submitting an [`accept` transaction](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#accept).
1. *Not* accept the outcome of their spin and respin at a discounted cost by submitting a
[`spin` transaction](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#spin).
1. Do nothing.

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
[*Bossting spins with GAMBIT*](#boosting-spins-with-gambit) section below.
3. Once the player makes the spin, start polling the chain's block number.
4. Once the spin transaction has been included in the blockchain, call [`inspectOutcome`](./docgen/src/src/DegenGambit.sol/contract.DegenGambit.md#inspectoutcome) to show the player the symbols on the reels, and what they would receive in prizes if they accepted that outcome.
5. Allow the players to either respin (go back to the beginning of this flow) or `accept` the outcome until `BlocksToAct` blocks have passed since they made their spin.
6. If `BlocksToAct` blocks pass after the player's last spin, go back to the beginning of this workflow.

## Boosting spins with GAMBIT