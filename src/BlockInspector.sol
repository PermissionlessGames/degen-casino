// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ArbSys} from "./ArbSys.sol";

/// @title BlockInspector
/// @dev This contract is for debugging purposes related to blockhashes and block nunbers on Arbitrum chains.
contract BlockInspector {
    bytes32 public BlockhashStore;

    function blockNumbers() external view returns (uint256, uint256) {
        uint256 arbBlockNumber = ArbSys(address(100)).arbBlockNumber();
        return (block.number, arbBlockNumber);
    }

    function hash(uint256 number) external view returns (bytes32) {
        return blockhash(number);
    }

    function arbBlockHash(uint256 number) external view returns (bytes32) {
        return ArbSys(address(100)).arbBlockHash(number);
    }

    function writeCurrentBlockHash() external {
        uint256 arbBlockNumber = ArbSys(address(100)).arbBlockNumber();
        BlockhashStore = ArbSys(address(100)).arbBlockHash(arbBlockNumber);
    }
}
