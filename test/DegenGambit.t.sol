// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DegenGambit} from "../src/DegenGambit.sol";
import {ArbSys} from "../src/ArbSys.sol";

contract ArbSysMock is ArbSys {
    function arbBlockNumber() external view returns (uint) {
        return block.number;
    }
}

contract TestableDegenGambit is DegenGambit {
    mapping(address => uint256) public EntropyForPlayer;

    constructor(
        uint256 blocksToAct,
        uint256 costToSpin,
        uint256 costToRespin
    ) DegenGambit(blocksToAct, costToSpin, costToRespin) {}

    function setEntropy(address player, uint256 entropy) public {
        EntropyForPlayer[player] = entropy;
    }

    function _entropy(address player) internal view override returns (uint256) {
        return EntropyForPlayer[player];
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract DegenGambitTest is Test {
    uint256 private constant SECONDS_PER_DAY = 60*60*24;
    uint256 private constant SECONDS_PER_WEEK = 60*60*24*7;

    TestableDegenGambit public degenGambit;

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
        degenGambit = new TestableDegenGambit(
            blocksToAct,
            costToSpin,
            costToRespin
        );

        vm.deal(address(degenGambit), costToSpin << 30);
        vm.deal(player1, 10 * costToSpin);

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

        uint256 cost = degenGambit.spinCost(player1);

        vm.startPrank(player1);

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

        uint256 entropy = 143946520351854296877309383;

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropy(player1, entropy);

        uint256 gameBalanceIntermediate = address(degenGambit).balance;
        uint256 playerBalanceIntermediate = player1.balance;

        assertEq(gameBalanceIntermediate, gameBalanceInitial + costToSpin);
        assertEq(playerBalanceIntermediate, playerBalanceInitial - costToSpin);

        uint256 expectedPayout = degenGambit.payout(2, 2, 2);
        assertEq(expectedPayout, 50 * costToSpin);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy
        ) = degenGambit.accept();

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(left, 2);
        assertEq(center, 2);
        assertEq(right, 2);
        assertEq(remainingEntropy, 0);
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

        uint256 entropy = 143946520351854296877309383;

        uint256 gameBalanceInitial = address(degenGambit).balance;
        uint256 playerBalanceInitial = player1.balance;

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);
        degenGambit.setEntropy(player1, entropy);

        uint256 gameBalanceIntermediate = address(degenGambit).balance;
        uint256 playerBalanceIntermediate = player1.balance;

        assertEq(gameBalanceIntermediate, gameBalanceInitial + costToSpin);
        assertEq(playerBalanceIntermediate, playerBalanceInitial - costToSpin);

        uint256 expectedPayout = degenGambit.payout(2, 2, 2);
        assertEq(expectedPayout, address(degenGambit).balance >> 6);

        vm.roll(block.number + 1);

        vm.expectEmit();
        emit Award(player1, expectedPayout);
        (
            uint256 left,
            uint256 center,
            uint256 right,
            uint256 remainingEntropy
        ) = degenGambit.accept();

        vm.stopPrank();

        uint256 gameBalanceFinal = address(degenGambit).balance;
        uint256 playerBalanceFinal = player1.balance;

        assertEq(left, 2);
        assertEq(center, 2);
        assertEq(right, 2);
        assertEq(remainingEntropy, 0);
        assertEq(gameBalanceFinal, gameBalanceIntermediate - expectedPayout);
        assertEq(
            playerBalanceFinal,
            playerBalanceIntermediate + expectedPayout
        );
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
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp/SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + SECONDS_PER_DAY);

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

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate + dailyStreakReward);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate + dailyStreakReward);
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
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + SECONDS_PER_DAY);

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, block.timestamp/SECONDS_PER_DAY);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + SECONDS_PER_DAY);

        vm.expectEmit();
        emit Transfer(address(0), player1, dailyStreakReward);
        vm.expectEmit();
        emit DailyStreak(player1, block.timestamp/SECONDS_PER_DAY);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(finalStreakDay, block.timestamp/SECONDS_PER_DAY);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyInitial + 2*dailyStreakReward);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceInitial + 2*dailyStreakReward);
    }

    function test_gambit_minted_on_streak_boosted() public {
        // Make sure the player has GAMBIT to boost with.
        degenGambit.mint(player1, 2);

        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 dailyStreakReward = degenGambit.DailyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp/SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial - 1);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial - 1);

        vm.roll(block.number + 1);
        // Tests the right end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + 2*SECONDS_PER_DAY - 1);

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

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate + dailyStreakReward - 1);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate + dailyStreakReward - 1);
    }

    function test_gambit_not_minted_before_streak_day_ticks() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp/SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + SECONDS_PER_DAY - 1);

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
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakDay = degenGambit.LastStreakDay(player1);
        assertEq(intermediateStreakDay, block.timestamp/SECONDS_PER_DAY);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp((block.timestamp/SECONDS_PER_DAY)*SECONDS_PER_DAY + 2*SECONDS_PER_DAY);

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
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp/SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + SECONDS_PER_WEEK);

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

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate + weeklyStreakReward);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate + weeklyStreakReward);
    }

    function test_gambit_minted_on_weekly_streak_regular_two_weeks_in_a_row() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 weeklyStreakReward = degenGambit.WeeklyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + SECONDS_PER_WEEK);

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, block.timestamp/SECONDS_PER_WEEK);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        vm.roll(block.number + 1);
        // Tests the left end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + SECONDS_PER_WEEK);

        vm.expectEmit();
        emit Transfer(address(0), player1, weeklyStreakReward);
        vm.expectEmit();
        emit WeeklyStreak(player1, block.timestamp/SECONDS_PER_WEEK);
        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 finalStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(finalStreakweek, block.timestamp/SECONDS_PER_WEEK);

        uint256 gambitSupplyFinal = degenGambit.totalSupply();
        uint256 playerGambitBalanceFinal = degenGambit.balanceOf(player1);

        assertEq(gambitSupplyFinal, gambitSupplyInitial + 2*weeklyStreakReward);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceInitial + 2*weeklyStreakReward);
    }

    function test_gambit_minted_on_weekly_streak_boosted() public {
        // Make sure the player has GAMBIT to boost with.
        degenGambit.mint(player1, 2);

        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        uint256 weeklyStreakReward = degenGambit.WeeklyStreakReward();

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, true);
        degenGambit.spin{value: costToSpin}(true);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp/SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial - 1);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial - 1);

        vm.roll(block.number + 1);
        // Tests the right end of the window for which the streak is active.
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + 2*SECONDS_PER_WEEK - 1);

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

        assertEq(gambitSupplyFinal, gambitSupplyIntermediate + weeklyStreakReward - 1);
        assertEq(playerGambitBalanceFinal, playerGambitBalanceIntermediate + weeklyStreakReward - 1);
    }

    function test_gambit_not_minted_before_streak_week_ticks() public {
        uint256 gambitSupplyInitial = degenGambit.totalSupply();
        uint256 playerGambitBalanceInitial = degenGambit.balanceOf(player1);

        vm.startPrank(player1);

        vm.expectEmit();
        emit Spin(player1, false);
        degenGambit.spin{value: costToSpin}(false);

        uint256 gambitSupplyIntermediate = degenGambit.totalSupply();
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp/SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + SECONDS_PER_WEEK - 1);

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
        uint256 playerGambitBalanceIntermediate = degenGambit.balanceOf(player1);

        uint256 intermediateStreakweek = degenGambit.LastStreakWeek(player1);
        assertEq(intermediateStreakweek, block.timestamp/SECONDS_PER_WEEK);

        assertEq(gambitSupplyIntermediate, gambitSupplyInitial);
        assertEq(playerGambitBalanceIntermediate, playerGambitBalanceInitial);

        vm.roll(block.number + 1);
        vm.warp((block.timestamp/SECONDS_PER_WEEK)*SECONDS_PER_WEEK + 2*SECONDS_PER_WEEK);

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

}
