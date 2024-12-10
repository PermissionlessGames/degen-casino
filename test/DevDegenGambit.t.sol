// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {ArbSys} from "../src/ArbSys.sol";
import {DevDegenGambit} from "../src/dev/DevDegenGambit.sol";
import {DegenGambit} from "../src/DegenGambit.sol";

contract ArbSysMock is ArbSys {
    function arbBlockNumber() external view returns (uint) {
        return block.number;
    }

    function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32) {
        return blockhash(arbBlockNum);
    }
}

contract DevDegenGambitTest is Test {
    uint256 private constant SECONDS_PER_DAY = 60 * 60 * 24;
    uint256 private constant SECONDS_PER_WEEK = 60 * 60 * 24 * 7;

    DevDegenGambit public devDegenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    uint256 player2PrivateKey = 0x14471;
    address player2 = vm.addr(player2PrivateKey);

    function setUp() public {
        devDegenGambit = new DevDegenGambit(
            blocksToAct,
            costToSpin,
            costToRespin
        );

        vm.deal(address(devDegenGambit), costToSpin << 30);
        vm.deal(player1, 10 * costToSpin);
        vm.deal(player2, 10 * costToSpin);

        ArbSysMock arbSys = new ArbSysMock();
        vm.etch(address(100), address(arbSys).code);
    }

    function test_version() public view {
        string memory version = devDegenGambit.version();
        assertEq(version, "1 - dev");
    }

    function test_entropy_generation_value() public {
        vm.startPrank(player1);

        uint256 initialEntropy = devDegenGambit.EntropyForPlayer(player1);
        uint256 setEntropy = devDegenGambit.setEntropyFromOutcomes(
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
        uint256 entropy = devDegenGambit.setEntropyFromOutcomes(
            left,
            center,
            right,
            player1,
            boosted
        );
        (uint256 oLeft, uint256 oCenter, uint256 oRight, ) = devDegenGambit
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
        devDegenGambit.setEntropyFromOutcomes(19, 19, 19, player1, false);

        vm.stopPrank();
    }

    function test_set_spin_cost() public {
        //assert initial cost is still set
        assertEq(costToSpin, devDegenGambit.CostToSpin());
        assertEq(costToRespin, devDegenGambit.CostToRespin());

        vm.startPrank(player1);
        devDegenGambit.setCostToSpin(0.05 ether);
        devDegenGambit.setCostToRespin(0.025 ether);

        vm.stopPrank();

        assertNotEq(devDegenGambit.CostToSpin(), costToSpin);
        assertNotEq(devDegenGambit.CostToRespin(), costToRespin);

        assertEq(devDegenGambit.CostToSpin(), 0.05 ether);
        assertEq(devDegenGambit.CostToRespin(), 0.025 ether);
    }

    function test_set_blocks_to_act() public {
        assertEq(blocksToAct, devDegenGambit.BlocksToAct());
        vm.startPrank(player1);
        devDegenGambit.setBlocksToAct(10);

        vm.stopPrank();

        assertNotEq(blocksToAct, devDegenGambit.BlocksToAct());
        assertEq(10, devDegenGambit.BlocksToAct());
    }

    function test_mint_gambit() public {
        assertEq(0, devDegenGambit.balanceOf(player1));

        vm.startPrank(player1);

        devDegenGambit.mintGambit(player1, 100);

        vm.stopPrank();

        assertEq(100, devDegenGambit.balanceOf(player1));
    }

    function test_set_streaks() public {
        uint256 initialDaily = devDegenGambit.LastStreakDay(player1);
        uint256 initialWeekly = devDegenGambit.LastStreakWeek(player1);
        assertNotEq(101, initialDaily);
        assertNotEq(102, initialWeekly);

        vm.startPrank(player1);

        devDegenGambit.setDailyStreak(101, player1);
        devDegenGambit.setWeeklyStreak(102, player1);

        vm.stopPrank();

        assertEq(101, devDegenGambit.LastStreakDay(player1));
        assertEq(102, devDegenGambit.LastStreakWeek(player1));
    }
}
