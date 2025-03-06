# ArbSys
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/cf1c5ca470c688d20285ece4b239db87eca65887/src/ArbSys.sol)

This code was adapted from the OffchainLabs/nitro-contracts repository: https://github.com/OffchainLabs/nitro-contracts.
Specifically, the ArbSys contract at commit 2ba206505edd15ad1e177392c454e89479959ca5:
https://github.com/OffchainLabs/nitro-contracts/blob/7396313311ab17cb30e2eef27cccf96f0a9e8f7f/src/precompiles/ArbSys.sol
Installing it as a foundry dependency had two issues:
1. Default tag did not support Solidity ^0.8.13.
2. The submodule is huge and we only need this interface.
To make it easier to mock, we have only retained the `arbBlockNumber` method. This is the only method we currently use in our games.


## Functions
### arbBlockNumber

Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)


```solidity
function arbBlockNumber() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|block number as int|


### arbBlockHash

Get Arbitrum block hash (reverts unless currentBlockNum-256 <= arbBlockNum < currentBlockNum)


```solidity
function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|block hash|


