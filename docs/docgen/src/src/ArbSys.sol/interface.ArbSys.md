# ArbSys
[Git Source](https://github.com//mrk-hub/degen-casino/blob/386cd0ea47a25253b55a2ea9b96de074c1a07d2b/src/ArbSys.sol)

This code was adapted from the arb-os repository: https://github.com/OffchainLabs/arb-os.
Specifically, the ArbSys contract at commit 234cf670016d675095110cd944cb82fde9c460b8:
https://github.com/OffchainLabs/arb-os/blob/234cf670016d675095110cd944cb82fde9c460b8/contracts/arbos/builtin/ArbSys.sol
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


