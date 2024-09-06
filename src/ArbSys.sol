// SPDX-License-Identifier: UNLICENSED

/**
 * This code was adapted from the arb-os repository: https://github.com/OffchainLabs/arb-os.
 * Specifically, the ArbSys contract at commit 234cf670016d675095110cd944cb82fde9c460b8:
 * https://github.com/OffchainLabs/arb-os/blob/234cf670016d675095110cd944cb82fde9c460b8/contracts/arbos/builtin/ArbSys.sol
 *
 * Installing it as a foundry dependency had two issues:
 * 1. Default tag did not support Solidity ^0.8.13.
 * 2. The submodule is huge and we only need this interface.
 *
 * To make it easier to mock, we have only retained the `arbBlockNumber` method. This is the only method we currently use in our games.
 */

pragma solidity >=0.4.21 <0.9.0;

/**
* @title Precompiled contract that exists in every Arbitrum chain at address(100), 0x0000000000000000000000000000000000000064. Exposes a variety of system-level functionality.
 */
interface ArbSys {
   /**
    * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
    * @return block number as int
     */ 
    function arbBlockNumber() external view returns (uint);
}
