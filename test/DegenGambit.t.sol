// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DegenGambit} from "../src/DegenGambit.sol";

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
    TestableDegenGambit public degenGambit;

    uint256 blocksToAct = 20;
    uint256 costToSpin = 0.1 ether;
    uint256 costToRespin = 0.07 ether;

    uint256 player1PrivateKey = 0x13371;
    address player1 = vm.addr(player1PrivateKey);

    // Events for testing
    event Spin(address indexed player, bool indexed bonus);
    event Award(address indexed player, uint256 value);

    function setUp() public {
        degenGambit = new TestableDegenGambit(
            blocksToAct,
            costToSpin,
            costToRespin
        );

        vm.deal(player1, 10 * costToSpin);
    }

    // Entropy was constructed using the generate_outcome_tests() method in the Degen Gambit game design notebook.
    function test_spin_2_2_2_0_false_large_pot() public {
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
}
