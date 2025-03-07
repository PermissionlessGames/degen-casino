// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DegenGambit} from "../src/DegenGambit.sol";
import {ArbSys} from "../src/ArbSys.sol";
import {DevDegenGambit} from "../src/dev/DevDegenGambit.sol";

contract ArbSysMock is ArbSys {
    function arbBlockNumber() external view returns (uint) {
        return block.number;
    }

    function arbBlockHash(uint256 arbBlockNum) external view returns (bytes32) {
        return blockhash(arbBlockNum);
    }
}

contract DegenGambitTest is Test {
    uint256 private constant SECONDS_PER_DAY = 60 * 60 * 24;
    uint256 private constant SECONDS_PER_WEEK = 60 * 60 * 24 * 7;

    DevDegenGambit public degenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    // Events for testing
    event Spin(address indexed player, bool indexed bonus);
    event Award(address indexed player, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event DailyStreak(address indexed player, uint256 day);
    event WeeklyStreak(address indexed player, uint256 week);

    function setUp() public {
        degenGambit = new DevDegenGambit(blocksToAct, costToSpin, costToRespin);

        vm.deal(address(degenGambit), costToSpin << 30);
        vm.deal(player1, 10 * costToSpin);
        vm.warp(14 days);
        ArbSysMock arbSys = new ArbSysMock();
        vm.etch(address(100), address(arbSys).code);
    }

    function test_spinCost_discount_in_and_only_in_first_blocksToAct_blocks_on_chain()
        public
    {
        uint256 i;
        for (i = 1; i <= blocksToAct; i++) {
            assertEq(block.number, i);
            assertEq(degenGambit.spinCost(player1), degenGambit.CostToRespin());
            vm.roll(block.number + 1);
        }

        assertEq(block.number, degenGambit.BlocksToAct() + 1);
        assertEq(degenGambit.spinCost(player1), degenGambit.CostToSpin());
    }

    function test_spin_fails_with_insufficient_value() public {
        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        uint256 cost = degenGambit.spinCost(player1);

        vm.startPrank(player1);

        vm.expectRevert(DegenGambit.InsufficientValue.selector);

        degenGambit.spin{value: cost - 1}(false);

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(gameBalanceFinal, gameBalanceInitial);
        assertEq(playerBalanceFinal, playerBalanceInitial);
    }

    function test_spin_takes_all_sent_value() public {
        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;
        vm.startPrank(player1);
        vm.roll(block.number + 15000);
        uint256 cost = degenGambit.spinCost(player1);

        degenGambit.spin{value: 2 * cost}(false);

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(gameBalanceFinal, gameBalanceInitial + 2 * cost);
        assertEq(playerBalanceFinal, playerBalanceInitial - 2 * cost);
    }

    function test_respin_succeeds_immediately() public {
        vm.roll(block.number + blocksToAct + 1);

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToRespin}(false);

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(
            gameBalanceFinal,
            gameBalanceInitial + costToSpin + costToRespin
        );
        assertEq(
            playerBalanceFinal,
            playerBalanceInitial - costToSpin - costToRespin
        );
    }

    function test_respin_succeeds_at_deadline() public {
        vm.roll(block.number + blocksToAct + 1);

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + blocksToAct);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToRespin}(false);

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(
            gameBalanceFinal,
            gameBalanceInitial + costToSpin + costToRespin
        );
        assertEq(
            playerBalanceFinal,
            playerBalanceInitial - costToSpin - costToRespin
        );
    }

    function test_respin_fails_after_deadline() public {
        vm.roll(block.number + blocksToAct + 1);

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + blocksToAct + 1);
        vm.expectRevert(DegenGambit.InsufficientValue.selector);
        degenGambit.spin{value: costToRespin}(false);

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(gameBalanceFinal, gameBalanceInitial + costToSpin);
        assertEq(playerBalanceFinal, playerBalanceInitial - costToSpin);
    }

    // Entropy was constructed using the generate_outcome_tests() method in the Degen Gambit game design notebook.
    function test_spin_2_2_2_0_false_large_pot() public {
        vm.roll(block.number + blocksToAct + 1);

        // Guarantees that the payout does not fall under balance-based clamping flow.
        vm.deal(address(degenGambit), costToSpin << 30);

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropyFromOutcomes(2, 2, 2, player1, false);

        uint256 gameBalanceIntermediate = address(degenGambit).balance;
        uint256 playerBalanceIntermediate = player1.balance;

        assertEq(gameBalanceIntermediate, gameBalanceInitial + costToSpin);
        assertEq(playerBalanceIntermediate, playerBalanceInitial - costToSpin);

        (
            uint256 expectedPayout,
            uint256 typeOfPrize,
            uint256 prizeIndex
        ) = degenGambit.payout(2, 2, 2);
        assertEq(expectedPayout, 50 * costToSpin);
        assertEq(typeOfPrize, 1);
        assertEq(prizeIndex, 2);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        ) = degenGambit.accept();

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(left, 2);
        assertEq(center, 2);
        assertEq(right, 2);
        assertEq(remainingEntropy, 0);
        assertEq(prize, expectedPayout);
        assertEq(gameBalanceFinal, gameBalanceIntermediate - expectedPayout);
        assertEq(
            playerBalanceFinal,
            playerBalanceIntermediate + expectedPayout
        );
    }

    // Entropy was constructed using the generate_outcome_tests() method in the Degen Gambit game design notebook.
    function test_spin_2_2_2_0_false_small_pot() public {
        vm.roll(block.number + blocksToAct + 1);

        // Guarantees that the payout falls under balance-based clamping flow.
        vm.deal(address(degenGambit), costToSpin);

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropyFromOutcomes(2, 2, 2, player1, false);

        uint256 gameBalanceIntermediate = address(degenGambit).balance;
        uint256 playerBalanceIntermediate = player1.balance;

        assertEq(gameBalanceIntermediate, gameBalanceInitial + costToSpin);
        assertEq(playerBalanceIntermediate, playerBalanceInitial - costToSpin);

        (
            uint256 expectedPayout,
            uint256 typeOfPrize,
            uint256 prizeIndex
        ) = degenGambit.payout(2, 2, 2);
        assertEq(expectedPayout, address(degenGambit).balance >> 6);
        assertEq(typeOfPrize, 1);
        assertEq(prizeIndex, 2);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy,
            uint256 prize
        ) = degenGambit.accept();

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(left, 2);
        assertEq(center, 2);
        assertEq(right, 2);
        assertEq(remainingEntropy, 0);
        assertEq(prize, expectedPayout);
        assertEq(gameBalanceFinal, gameBalanceIntermediate - expectedPayout);
        assertEq(
            playerBalanceFinal,
            playerBalanceIntermediate + expectedPayout
        );
    }

    function test_spin_2_3_2_0_false_gambit_mint() public {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;
        uint256 prize;
        vm.roll(block.number + blocksToAct + 1);

        uint256 entropy = degenGambit.generateEntropyForUnmodifiedReelOutcome(
            2,
            3,
            2
        );

        uint256 gameBalanceBefore = address(degenGambit).balance;
        uint256 playerBalanceBefore = player1.balance;
        uint256 gambitSupplyBefore = degenGambit.totalSupply();
        uint256 playerGambitBalanceBefore = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropy(player1, entropy);

        assertEq(address(degenGambit).balance, gameBalanceBefore + costToSpin);
        assertEq(player1.balance, playerBalanceBefore - costToSpin);

        uint256 expectedPayout;
        {
            uint256 typeOfPrize;
            uint256 prizeIndex;
            (expectedPayout, typeOfPrize, prizeIndex) = degenGambit.payout(
                2,
                3,
                2
            );
            assertEq(expectedPayout, degenGambit.MinorGambitPrize());
            assertEq(typeOfPrize, 20);
            assertEq(prizeIndex, 1);
        }
        assertEq(degenGambit.LastSpinBoosted(player1), false);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (left, center, right, remainingEntropy, prize) = degenGambit.accept();

        vm.stopPrank();

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(left, 2);
        assertEq(center, 3);
        assertEq(right, 2);
        assertEq(remainingEntropy, 0);
        assertEq(prize, expectedPayout);
        assertEq(address(degenGambit).balance, gameBalanceBefore + costToSpin);
        assertEq(
            gambitSupplyFinal,
            gambitSupplyBefore + degenGambit.MinorGambitPrize()
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceBefore + degenGambit.MinorGambitPrize()
        );

        assertEq(degenGambit.LastSpinBoosted(player1), false);
    }

    function test_spin_2_3_16_0_false_gambit_mint() public {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;
        uint256 prize;
        vm.roll(block.number + blocksToAct + 1);

        uint256 entropy = degenGambit.generateEntropyForUnmodifiedReelOutcome(
            2,
            3,
            16
        );

        uint256 gameBalanceBefore = address(degenGambit).balance;
        uint256 playerBalanceBefore = player1.balance;
        uint256 gambitSupplyBefore = degenGambit.totalSupply();
        uint256 playerGambitBalanceBefore = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropy(player1, entropy);

        assertEq(address(degenGambit).balance, gameBalanceBefore + costToSpin);
        assertEq(player1.balance, playerBalanceBefore - costToSpin);

        uint256 expectedPayout;
        {
            uint256 typeOfPrize;
            uint256 prizeIndex;
            (expectedPayout, typeOfPrize, prizeIndex) = degenGambit.payout(
                2,
                3,
                16
            );
            assertEq(expectedPayout, degenGambit.MajorGambitPrize());
            assertEq(typeOfPrize, 20);
            assertEq(prizeIndex, 0);
        }
        assertEq(degenGambit.LastSpinBoosted(player1), false);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (left, center, right, remainingEntropy, prize) = degenGambit.accept();

        vm.stopPrank();

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(left, 2);
        assertEq(center, 3);
        assertEq(right, 16);
        assertEq(remainingEntropy, 0);
        assertEq(prize, expectedPayout);
        assertEq(address(degenGambit).balance, gameBalanceBefore + costToSpin);
        assertEq(
            gambitSupplyFinal,
            gambitSupplyBefore + degenGambit.MajorGambitPrize()
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceBefore + degenGambit.MajorGambitPrize()
        );

        assertEq(degenGambit.LastSpinBoosted(player1), false);
    }

    // Entropy was constructed using the generate_outcome_tests() method in the Degen Gambit game design notebook.
    function test_spin_17_17_17_0_true_large_pot() public {
        uint256 left;
        uint256 center;
        uint256 right;
        uint256 remainingEntropy;
        uint256 prize;
        vm.roll(block.number + blocksToAct + 1);

        // Guarantees that the payout does not fall under balance-based clamping flow.
        vm.deal(address(degenGambit), costToSpin << 30);

        // Guarantees that the player has enough GAMBIT for a boosted spin

        degenGambit.mintGambit(player1, 2 * (10 ** degenGambit.decimals()));

        uint256 entropy = degenGambit.generateEntropyForImprovedReelOutcome(
            17,
            17,
            17
        );

        uint256 gameBalanceBefore = address(degenGambit).balance;
        uint256 playerBalanceBefore = player1.balance;
        uint256 gambitSupplyBefore = degenGambit.totalSupply();
        uint256 playerGambitBalanceBefore = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Transfer(player1, address(0), 1 * (10 ** degenGambit.decimals()));
        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);
        degenGambit.setEntropy(player1, entropy);

        assertEq(address(degenGambit).balance, gameBalanceBefore + costToSpin);
        assertEq(player1.balance, playerBalanceBefore - costToSpin);

        gameBalanceBefore = address(degenGambit).balance;
        playerBalanceBefore = player1.balance;
        uint256 expectedPayout;
        {
            uint256 typeOfPrize;
            uint256 prizeIndex;
            (expectedPayout, typeOfPrize, prizeIndex) = degenGambit.payout(
                17,
                17,
                17
            );
            assertEq(expectedPayout, gameBalanceBefore >> 1);
            assertEq(typeOfPrize, 1);
        }
        assertEq(degenGambit.LastSpinBoosted(player1), true);

        vm.roll(block.number + 1);

        // This guarantees that the outcome isn't coming from the regular distributions but the boosted ones.
        (left, center, right, ) = degenGambit.outcome(entropy, false);

        assertNotEq(left, 17);
        assertNotEq(center, 17);
        assertNotEq(right, 17);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (left, center, right, remainingEntropy, prize) = degenGambit.accept();

        vm.stopPrank();

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(left, 17);
        assertEq(center, 17);
        assertEq(right, 17);
        assertEq(remainingEntropy, 0);
        assertEq(prize, expectedPayout);
        assertEq(
            address(degenGambit).balance,
            gameBalanceBefore - expectedPayout
        );
        assertEq(player1.balance, playerBalanceBefore + expectedPayout);
        assertEq(
            gambitSupplyFinal,
            gambitSupplyBefore - (10 ** degenGambit.decimals())
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceBefore - (10 ** degenGambit.decimals())
        );

        assertEq(degenGambit.LastSpinBoosted(player1), false);
    }

    function test_gambit_minted_on_streak_regular() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 dailyStreakReward = degenGambit.DailyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp / SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                SECONDS_PER_DAY
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, intermediateStreakDay + 1);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, intermediateStreakDay + 1);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyIntermediate + dailyStreakReward
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceIntermediate + dailyStreakReward
        );
    }

    function test_gambit_minted_on_streak_regular_two_days_in_a_row() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 dailyStreakReward = degenGambit.DailyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                SECONDS_PER_DAY
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, block.timestamp / SECONDS_PER_DAY);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                SECONDS_PER_DAY
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, block.timestamp / SECONDS_PER_DAY);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, block.timestamp / SECONDS_PER_DAY);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyInitial + 2 * dailyStreakReward
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceInitial + 2 * dailyStreakReward
        );
    }

    function test_gambit_minted_on_streak_boosted() public {
        // Make sure the player has GAMBIT to boost with.
        uint256 singleDegenGambitToken = 10 ** degenGambit.decimals();
        degenGambit.mintGambit(player1, 2 * singleDegenGambitToken);

        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 dailyStreakReward = degenGambit.DailyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, true);

        degenGambit.spin{value: costToSpin}(true);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp / SECONDS_PER_DAY);

        assertEq(
            gambitSupplyIntermediate,
            gambitSupplyInitial - singleDegenGambitToken
        );
        assertEq(
            playerGambitBalanceIntermediate,
            playerGambitBalanceInitial - singleDegenGambitToken
        );

        vm.roll(block.number + 1);
        // Tests the right end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                2 *
                SECONDS_PER_DAY -
                1
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, intermediateStreakDay + 1);
        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, intermediateStreakDay + 1);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyIntermediate +
                dailyStreakReward -
                singleDegenGambitToken
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceIntermediate +
                dailyStreakReward -
                singleDegenGambitToken
        );
    }

    function test_gambit_not_minted_before_streak_day_ticks() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp / SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                SECONDS_PER_DAY -
                1
        );

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, intermediateStreakDay);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate);
    }

    function test_gambit_not_minted_after_more_than_one_day() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp / SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp(
            (block.timestamp / SECONDS_PER_DAY) *
                SECONDS_PER_DAY +
                2 *
                SECONDS_PER_DAY
        );

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, intermediateStreakDay + 2);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate);
    }

    function test_gambit_minted_on_weekly_streak_regular() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 weeklyStreakReward = degenGambit.WeeklyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp / SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                SECONDS_PER_WEEK
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, intermediateStreakweek + 1);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, intermediateStreakweek + 1);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyIntermediate + weeklyStreakReward
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceIntermediate + weeklyStreakReward
        );
    }

    function test_gambit_minted_on_weekly_streak_regular_two_weeks_in_a_row()
        public
    {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 weeklyStreakReward = degenGambit.WeeklyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                SECONDS_PER_WEEK
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, block.timestamp / SECONDS_PER_WEEK);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                SECONDS_PER_WEEK
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, block.timestamp / SECONDS_PER_WEEK);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, block.timestamp / SECONDS_PER_WEEK);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyInitial + 2 * weeklyStreakReward
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceInitial + 2 * weeklyStreakReward
        );
    }

    function test_gambit_minted_on_weekly_streak_boosted() public {
        // Make sure the player has GAMBIT to boost with.
        uint256 singleDegenGambitToken = 10 ** degenGambit.decimals();
        degenGambit.mintGambit(player1, 2 * singleDegenGambitToken);

        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 weeklyStreakReward = degenGambit.WeeklyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp / SECONDS_PER_WEEK);

        assertEq(
            gambitSupplyIntermediate,
            gambitSupplyInitial - singleDegenGambitToken
        );
        assertEq(
            playerGambitBalanceIntermediate,
            playerGambitBalanceInitial - singleDegenGambitToken
        );

        vm.roll(block.number + 1);
        // Tests the right end of the window for which the streak is active.
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                2 *
                SECONDS_PER_WEEK -
                1
        );

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, intermediateStreakweek + 1);
        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, intermediateStreakweek + 1);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(
            gambitSupplyFinal,
            gambitSupplyIntermediate +
                weeklyStreakReward -
                singleDegenGambitToken
        );
        assertEq(
            playerGambitBalanceFinal,
            playerGambitBalanceIntermediate +
                weeklyStreakReward -
                singleDegenGambitToken
        );
    }

    function test_gambit_not_minted_before_streak_week_ticks() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp / SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                SECONDS_PER_WEEK -
                1
        );

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, intermediateStreakweek);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate);
    }

    function test_gambit_not_minted_after_more_than_one_week() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(
            player1
        );

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp / SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp(
            (block.timestamp / SECONDS_PER_WEEK) *
                SECONDS_PER_WEEK +
                2 *
                SECONDS_PER_WEEK
        );

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, intermediateStreakweek + 2);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate);
    }

    function test_prizes_and_payout_match() public {
        vm.expectRevert(DegenGambit.OutcomeOutOfBounds.selector);
        degenGambit.payout(19, 19, 19);
        (uint256[] memory prizes, uint256[] memory typeOfPrize) = degenGambit
            .prizes();
        //No Payout
        (uint256 payout, uint256 prizeType, uint256 prizeIndex) = degenGambit
            .payout(0, 0, 0);
        assertEq(0, payout);
        assertEq(0, prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(0, 1, 2);
        assertEq(0, payout);
        assertEq(0, prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(1, 2, 3);
        assertEq(0, payout);
        assertEq(0, prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(0, 16, 0);
        assertEq(0, payout);
        assertEq(0, prizeType);
        assertEq(0, prizeIndex);

        //Prizes
        (payout, prizeType, prizeIndex) = degenGambit.payout(1, 16, 2);
        assertEq(prizes[0], payout);
        assertEq(typeOfPrize[0], prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 2, 16);
        assertEq(prizes[0], payout);
        assertEq(typeOfPrize[0], prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 16, 17);
        assertEq(prizes[0], payout);
        assertEq(typeOfPrize[0], prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 16, 6);
        assertEq(prizes[0], payout);
        assertEq(typeOfPrize[0], prizeType);
        assertEq(0, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(1, 6, 1);
        assertEq(prizes[1], payout);
        assertEq(typeOfPrize[1], prizeType);
        assertEq(1, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(15, 1, 15);
        assertEq(prizes[1], payout);
        assertEq(typeOfPrize[1], prizeType);
        assertEq(1, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(1, 1, 1);
        assertEq(prizes[2], payout);
        assertEq(typeOfPrize[2], prizeType);
        assertEq(2, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(15, 15, 15);
        assertEq(prizes[2], payout);
        assertEq(typeOfPrize[2], prizeType);
        assertEq(2, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(1, 16, 1);
        assertEq(prizes[3], payout);
        assertEq(typeOfPrize[3], prizeType);
        assertEq(3, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(15, 16, 15);
        assertEq(prizes[3], payout);
        assertEq(typeOfPrize[3], prizeType);
        assertEq(3, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 17, 16);
        assertEq(prizes[4], payout);
        assertEq(typeOfPrize[4], prizeType);
        assertEq(4, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 17, 18);
        assertEq(prizes[5], payout);
        assertEq(typeOfPrize[5], prizeType);
        assertEq(5, prizeIndex);

        (payout, prizeType, prizeIndex) = degenGambit.payout(16, 16, 16);
        assertEq(prizes[6], payout);
        assertEq(typeOfPrize[6], prizeType);
        assertEq(6, prizeIndex);
    }

    function test_streak_count_fail_under_one_week() public {
        vm.warp(0);
        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);
        uint256 cost = degenGambit.spinCost(player1);
        for (uint i = 0; i < 7; i++) {
            cost = degenGambit.spinCost(player1);
            vm.expectRevert();
            degenGambit.spin{value: cost}(false);
            vm.warp(block.timestamp + 1 days);
        }
        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(gameBalanceFinal, gameBalanceInitial);
        assertEq(playerBalanceFinal, playerBalanceInitial);
    }

    function internal_streak_length(uint _days) internal {
        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        uint cost;
        for (uint i = 0; i < _days; i++) {
            cost = degenGambit.spinCost(player1);
            degenGambit.spin{value: cost}(false);
            vm.warp(block.timestamp + 1 days);
        }

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(gameBalanceFinal, gameBalanceInitial + (_days * cost));
        assertEq(playerBalanceFinal, playerBalanceInitial - (_days * cost));
    }

    function test_streak_daily_length_seven_days() public {
        vm.startPrank(player1);

        internal_streak_length(7);
        assertEq(degenGambit.CurrentWeeklyStreakLength(player1), 0);
        assertEq(degenGambit.CurrentDailyStreakLength(player1), 6);
    }

    function test_streak_weekly_length_seven_weeks() public {
        vm.startPrank(player1);
        vm.deal(player1, 49 * costToSpin);
        internal_streak_length(49);
        assertEq(degenGambit.CurrentWeeklyStreakLength(player1), 6);
        assertEq(degenGambit.CurrentDailyStreakLength(player1), 48);
    }

    function test_daily_weekly_streak_length_reset() public {
        vm.startPrank(player1);

        uint256 initialDaily = degenGambit.CurrentDailyStreakLength(player1);
        uint256 initialWeekly = degenGambit.CurrentWeeklyStreakLength(player1);
        degenGambit.setDailyStreakLength(10, player1);
        degenGambit.setWeeklyStreakLength(10, player1);

        assertEq(
            degenGambit.CurrentDailyStreakLength(player1),
            initialDaily + 10
        );
        assertEq(
            degenGambit.CurrentWeeklyStreakLength(player1),
            initialWeekly + 10
        );

        degenGambit.spin{value: costToSpin}(false);

        assertEq(degenGambit.CurrentDailyStreakLength(player1), 0);
        assertEq(degenGambit.CurrentWeeklyStreakLength(player1), 0);
    }

    function test_latest_winners() public {
        // Roll forward and allocate large amount of ETH to contract
        vm.roll(block.number + blocksToAct + 1);
        vm.deal(address(degenGambit), 100 ether);

        // Create test players
        address player0 = address(0x0101);
        address player2 = address(0x2);
        address player3 = address(0x3);
        address player4 = address(0x4);
        address player5 = address(0x5);
        address player6 = address(0x6);
        address player7 = address(0x7);

        // Fund player1 call for all players
        vm.deal(player1, costToSpin * 10);
        vm.startPrank(player1);
        // Segment 1: Spin for all players
        degenGambit.spinFor{value: costToSpin}(player0, player0, false);
        degenGambit.spinFor{value: costToSpin}(player1, player1, false);
        degenGambit.spinFor{value: costToSpin}(player2, player2, false);
        degenGambit.spinFor{value: costToSpin}(player3, player3, false);
        degenGambit.spinFor{value: costToSpin}(player4, player4, false);
        degenGambit.spinFor{value: costToSpin}(player5, player5, false);
        degenGambit.spinFor{value: costToSpin}(player6, player6, false);
        degenGambit.spinFor{value: costToSpin}(player7, player7, false);
        vm.stopPrank();
        // Segment 2: Set entropy for all players
        degenGambit.setEntropyFromOutcomes(1, 2, 3, player0, false); //does not win
        degenGambit.setEntropyFromOutcomes(16, 1, 2, player1, false); // 1 major symbol with no other prize options
        degenGambit.setEntropyFromOutcomes(2, 4, 2, player2, false); // 2 matching outside minor symbols with a different minor symbol in the middle
        degenGambit.setEntropyFromOutcomes(2, 2, 2, player3, false); // 3 matching minor symbols
        degenGambit.setEntropyFromOutcomes(2, 16, 2, player4, false); // 1 major symbol inside with 2 minor symbols outside
        degenGambit.setEntropyFromOutcomes(16, 17, 16, player5, false); // 2 mathcing major symbols outside with 1 major symbol inside
        degenGambit.setEntropyFromOutcomes(17, 16, 18, player6, false); // 3 different major symbols
        degenGambit.setEntropyFromOutcomes(18, 18, 18, player7, false); // 3 matching major symbols

        // Segment 3: Roll block forward
        vm.roll(block.number + 1);

        // Segment 4: Accept outcomes for all players
        vm.startPrank(player1);
        {
            (, , , , uint256 nullPrize) = degenGambit.acceptFor(player0);
            assertEq(nullPrize, 0, "Player0 should not win");
        }
        {
            (, , , , uint256 prize1) = degenGambit.acceptFor(player1);
            assertEq(
                degenGambit.Prize0Winner(),
                player1,
                "Player1 should be first winner"
            );
            assertEq(
                degenGambit.Prize0WonAmount(),
                prize1,
                "Player1 should win 0.1 ETH"
            );
            assertEq(
                degenGambit.Prize0LastWonTimestamp(),
                block.timestamp,
                "Player1 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize2) = degenGambit.acceptFor(player2);
            assertEq(
                degenGambit.Prize1Winner(),
                player2,
                "Player2 should be second winner"
            );
            assertEq(
                degenGambit.Prize1WonAmount(),
                prize2,
                "Player2 should win 0.2 ETH"
            );
            assertEq(
                degenGambit.Prize1LastWonTimestamp(),
                block.timestamp,
                "Player2 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize3) = degenGambit.acceptFor(player3);
            assertEq(
                degenGambit.Prize2Winner(),
                player3,
                "Player3 should be third winner"
            );
            assertEq(
                degenGambit.Prize2WonAmount(),
                prize3,
                "Player3 should win 0.3 ETH"
            );
            assertEq(
                degenGambit.Prize2LastWonTimestamp(),
                block.timestamp,
                "Player3 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize4) = degenGambit.acceptFor(player4);
            assertEq(
                degenGambit.Prize3Winner(),
                player4,
                "Player4 should be fourth winner"
            );
            assertEq(
                degenGambit.Prize3WonAmount(),
                prize4,
                "Player4 should win 0.4 ETH"
            );
            assertEq(
                degenGambit.Prize3LastWonTimestamp(),
                block.timestamp,
                "Player4 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize5) = degenGambit.acceptFor(player5);
            assertEq(
                degenGambit.Prize4Winner(),
                player5,
                "Player5 should be fifth winner"
            );
            assertEq(
                degenGambit.Prize4WonAmount(),
                prize5,
                "Player5 should win 0.5 ETH"
            );
            assertEq(
                degenGambit.Prize4LastWonTimestamp(),
                block.timestamp,
                "Player5 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize6) = degenGambit.acceptFor(player6);
            assertEq(
                degenGambit.Prize5Winner(),
                player6,
                "Player6 should be sixth winner"
            );
            assertEq(
                degenGambit.Prize5WonAmount(),
                prize6,
                "Player6 should win 0.6 ETH"
            );
            assertEq(
                degenGambit.Prize5LastWonTimestamp(),
                block.timestamp,
                "Player6 timestamp should be set"
            );
        }
        {
            (, , , , uint256 prize7) = degenGambit.acceptFor(player7);
            assertEq(
                degenGambit.Prize6Winner(),
                player7,
                "Player7 should be seventh winner"
            );
            assertEq(
                degenGambit.Prize6WonAmount(),
                prize7,
                "Player7 should win 0.7 ETH"
            );
            assertEq(
                degenGambit.Prize6LastWonTimestamp(),
                block.timestamp,
                "Player7 timestamp should be set"
            );
        }
        vm.stopPrank();
    }

    function test_latest_winners_same_prize() public {
        vm.roll(block.number + blocksToAct + 1);
        vm.deal(address(degenGambit), costToSpin << 30);

        // First winner with three 2s (50x prize)
        vm.startPrank(player1);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropyFromOutcomes(2, 2, 2, player1, false);
        (uint256 payout1, , uint256 index1) = degenGambit.payout(2, 2, 2);
        vm.roll(block.number + 1);
        degenGambit.accept();
        vm.stopPrank();

        // Verify first winner is recorded
        assertEq(degenGambit.Prize2Winner(), player1);
        assertEq(degenGambit.Prize2WonAmount(), payout1);
        assertEq(degenGambit.Prize2LastWonTimestamp(), block.timestamp);

        // Second player wins the same prize (three 2s - 50x prize)
        address player2 = address(0x2);
        vm.deal(player2, costToSpin);
        vm.startPrank(player2);
        vm.expectEmit();
        emit Spin(player2, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropyFromOutcomes(2, 2, 2, player2, false);
        (uint256 payout2, , uint256 index2) = degenGambit.payout(2, 2, 2);
        vm.roll(block.number + 1);
        degenGambit.accept();
        vm.stopPrank();

        assertEq(index1, index2);

        // Verify second winner replaced first winner in the same slot
        assertEq(degenGambit.Prize2Winner(), player2);
        assertEq(degenGambit.Prize2WonAmount(), payout2);
        assertEq(degenGambit.Prize2LastWonTimestamp(), block.timestamp);
    }
}
