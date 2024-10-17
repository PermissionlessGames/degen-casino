// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ArbSys} from "./ArbSys.sol";

/// @title BlockInspector
/// @dev This contract is for debugging purposes related to blockhashes and block nunbers on Arbitrum chains.
contract BlockInspector {
    function inspect()
        external
        view
        returns (uint256, uint256, bytes32, bytes32)
    {
        uint256 arbBlockNumber = ArbSys(address(100)).arbBlockNumber();
        return (
            block.number,
            arbBlockNumber,
            blockhash(block.number),
            blockhash(arbBlockNumber)
        );
    }

    function hash(uint256 number) external view returns (bytes32) {
        return blockhash(number);
    }
}
