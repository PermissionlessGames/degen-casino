// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DegenGambit} from "../src/DegenGambit.sol";

contract DegenGambitTest is Test {
    DegenGambit public degenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    function setUp() public {
        degenGambit = new DegenGambit(blocksToAct, costToSpin, costToRespin);
    }

    function test_configuration() public view {
        assertEq(degenGambit.BlocksToAct(), blocksToAct);
        assertEq(degenGambit.CostToSpin(), costToSpin);
        assertEq(degenGambit.CostToRespin(), costToRespin);
    }

    function test_supportsInterface() public view {
        assertEq(degenGambit.supportsInterface(0x01ffc9a7), true);
        assertEq(degenGambit.supportsInterface(0x36372b07), true);
    }

    function test_ERC20Metadata() public view {
        assertEq(degenGambit.name(), "Degen's Gambit");
        assertEq(degenGambit.symbol(), "GAMBIT");
        assertEq(degenGambit.decimals(), 0);
    }
}
