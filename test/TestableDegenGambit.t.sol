// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {ArbSys} from "../src/ArbSys.sol";
import {TestableDegenGambit} from "../src/testable/TestableDegenGambit.sol";
import {DegenGambit} from "../src/DegenGambit.sol";

contract ArbSysMock is ArbSys {
    function arbBlockNumber() external view returns (uint) {
        return block.number;
    }

    function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32) {
        return blockhash(arbBlockNum);
    }
}

contract TestableDegenGambitTest is Test {
    uint256 private constant SECONDS_PER_DAY = 60 * 60 * 24;
    uint256 private constant SECONDS_PER_WEEK = 60 * 60 * 24 * 7;

    TestableDegenGambit public testableDegenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    uint256 player2PrivateKey = 0x14471;
    address player2 = vm.addr(player2PrivateKey);

    function setUp() public {
        testableDegenGambit = new TestableDegenGambit(
            blocksToAct,
            costToSpin,
            costToRespin
        );

        vm.deal(address(testableDegenGambit), costToSpin << 30);
        vm.deal(player1, 10 * costToSpin);
        vm.deal(player2, 10 * costToSpin);

        ArbSysMock arbSys = new ArbSysMock();
        vm.etch(address(100), address(arbSys).code);
    }

    function test_version() public view {
        string memory version = testableDegenGambit.version();
        assertEq(version, "1 - debuggable");
    }

    function test_entropy_generation_value() public {
        vm.startPrank(player1);

        uint256 initialEntropy = testableDegenGambit.EntropyForPlayer(player1);
        uint256 setEntropy = testableDegenGambit.setEntropyFromOutcomes(
            12,
            12,
            12,
            player1,
            false
        );

        vm.stopPrank();
        assertNotEq(initialEntropy, setEntropy);
    }

    function test_set_outcome_from_entropy(
        uint256 left,
        uint256 center,
        uint256 right,
        bool boosted
    ) internal {
        uint256 entropy = testableDegenGambit.setEntropyFromOutcomes(
            left,
            center,
            right,
            player1,
            boosted
        );
        (uint256 oLeft, uint256 oCenter, uint256 oRight, ) = testableDegenGambit
            .outcome(entropy, boosted);
        assertEq(left, oLeft);
        assertEq(center, oCenter);
        assertEq(right, oRight);
    }

    function test_entropy_generation_outcomes_false() public {
        vm.startPrank(player1);

        for (uint i = 0; i < 19; i++) {
            test_set_outcome_from_entropy(i, i, i, false);
        }
    }

    function test_entropy_generation_outcomes_true() public {
        vm.startPrank(player1);

        for (uint i = 0; i < 19; i++) {
            test_set_outcome_from_entropy(i, i, i, true);
        }
    }

    function test_entropy_generation_outcomes_out_of_bounds_revert() public {
        vm.startPrank(player1);

        vm.expectRevert(DegenGambit.OutcomeOutOfBounds.selector);
        testableDegenGambit.setEntropyFromOutcomes(19, 19, 19, player1, false);

        vm.stopPrank();
    }

    function test_set_spin_cost() public {
        //assert initial cost is still set
        assertEq(costToSpin, testableDegenGambit.CostToSpin());
        assertEq(costToRespin, testableDegenGambit.CostToRespin());

        vm.startPrank(player1);
        testableDegenGambit.setCostToSpin(0.05 ether);
        testableDegenGambit.setCostToRespin(0.025 ether);

        vm.stopPrank();

        assertNotEq(testableDegenGambit.CostToSpin(), costToSpin);
        assertNotEq(testableDegenGambit.CostToRespin(), costToRespin);

        assertEq(testableDegenGambit.CostToSpin(), 0.05 ether);
        assertEq(testableDegenGambit.CostToRespin(), 0.025 ether);
    }

    function test_set_blocks_to_act() public {
        assertEq(blocksToAct, testableDegenGambit.BlocksToAct());
        vm.startPrank(player1);
        testableDegenGambit.setBlocksToAct(10);

        vm.stopPrank();

        assertNotEq(blocksToAct, testableDegenGambit.BlocksToAct());
        assertEq(10, testableDegenGambit.BlocksToAct());
    }

    function test_mint_gambit() public {
        assertEq(0, testableDegenGambit.balanceOf(player1));

        vm.startPrank(player1);

        testableDegenGambit.mintGambit(player1, 100);

        vm.stopPrank();

        assertEq(100, testableDegenGambit.balanceOf(player1));
    }

    function test_set_streaks() public {
        uint256 initialDaily = testableDegenGambit.LastStreakDay(player1);
        uint256 initialWeekly = testableDegenGambit.LastStreakWeek(player1);
        assertNotEq(101, initialDaily);
        assertNotEq(102, initialWeekly);

        vm.startPrank(player1);

        testableDegenGambit.setDailyStreak(101, player1);
        testableDegenGambit.setWeeklyStreak(102, player1);

        vm.stopPrank();

        assertEq(101, testableDegenGambit.LastStreakDay(player1));
        assertEq(102, testableDegenGambit.LastStreakWeek(player1));
    }
}
