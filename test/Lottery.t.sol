// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/lottery/Lottery.sol"; // Ensure path is correct

contract LotteryTest is Test, Lottery {
    address player1 = address(0x1);
    address player2 = address(0x2);

    function setUp() public {
        //nextLotteryId = 1; // Reset lottery ID for consistent testing
    }

    function testCreateLottery() public {
        createLottery(50, 5); // Max number 50, pick 5

        assertEq(lotteries[1].lotteryId, 1, "Lottery ID should be 0");
        assertEq(lotteries[1].maxNumber, 50, "Max number should be 50");
        assertEq(
            lotteries[1].numbersToPick,
            5,
            "Should require picking 5 numbers"
        );
        assertTrue(lotteries[1].isActive, "Lottery should be active");
    }

    function testProcessTicketPurchase() public {
        createLottery(50, 5);
        uint256[] memory numbers = new uint256[](5);
        numbers[0] = 1;
        numbers[1] = 3;
        numbers[2] = 5;
        numbers[3] = 7;
        numbers[4] = 9;

        bool success = processTicketPurchase(
            currentLotteryId,
            numbers,
            player1
        );
        assertTrue(success, "Ticket purchase should succeed");
    }

    function testHasMatching() public {
        createLottery(50, 5);
        uint256[] memory numbers = new uint256[](5);
        numbers[0] = 1;
        numbers[1] = 2;
        numbers[2] = 3;
        numbers[3] = 4;
        numbers[4] = 5;

        processTicketPurchase(currentLotteryId, numbers, player1);

        uint256[] memory winningNumbers = new uint256[](5);
        winningNumbers[0] = 1;
        winningNumbers[1] = 2;
        winningNumbers[2] = 6;
        winningNumbers[3] = 7;
        winningNumbers[4] = 8;

        setWinningNumbers(currentLotteryId, winningNumbers);

        uint256 matching = hasMatching(currentLotteryId, player1, 0);
        assertEq(matching, 2, "Should have 2 matching numbers");
    }

    function testClaimPrize() public {
        createLottery(50, 5);
        uint256[] memory numbers = new uint256[](5);
        numbers[0] = 1;
        numbers[1] = 2;
        numbers[2] = 3;
        numbers[3] = 4;
        numbers[4] = 5;

        processTicketPurchase(currentLotteryId, numbers, player1);

        uint256[] memory winningNumbers = new uint256[](5);
        winningNumbers[0] = 1;
        winningNumbers[1] = 2;
        winningNumbers[2] = 3;
        winningNumbers[3] = 4;
        winningNumbers[4] = 5;

        setWinningNumbers(currentLotteryId, winningNumbers);

        setClaimedPrize(currentLotteryId, player1, 0);

        // Try claiming again - should revert
        vm.expectRevert("Lottery: Prize already claimed");
        setClaimedPrize(currentLotteryId, player1, 0);
    }

    function testGetWinningNumbers() public {
        createLottery(50, 5);
        uint256[] memory winningNumbers = new uint256[](5);
        winningNumbers[0] = 1;
        winningNumbers[1] = 2;
        winningNumbers[2] = 3;
        winningNumbers[3] = 4;
        winningNumbers[4] = 5;

        setWinningNumbers(currentLotteryId, winningNumbers);

        uint256[] memory decodedWinningNumbers = getWinningNumbers(
            currentLotteryId
        );

        assertEq(
            decodedWinningNumbers.length,
            5,
            "Winning numbers should be length 5"
        );
        assertEq(decodedWinningNumbers[0], 1, "First number should be 1");
        assertEq(decodedWinningNumbers[1], 2, "Second number should be 2");
        assertEq(decodedWinningNumbers[2], 3, "Third number should be 3");
        assertEq(decodedWinningNumbers[3], 4, "Fourth number should be 4");
        assertEq(decodedWinningNumbers[4], 5, "Fifth number should be 5");
    }

    function testGetPlayersForNumbers() public {
        createLottery(50, 5);
        uint256[] memory numbers = new uint256[](5);
        numbers[0] = 1;
        numbers[1] = 2;
        numbers[2] = 3;
        numbers[3] = 4;
        numbers[4] = 5;

        bool isTrue = processTicketPurchase(currentLotteryId, numbers, player1);
        assert(isTrue);
        isTrue = false;
        isTrue = processTicketPurchase(currentLotteryId, numbers, player2);
        assert(isTrue);
        address[] memory players = getPlayersForNumbers(
            currentLotteryId,
            numbers
        );

        assertEq(players.length, 2, "Should return 2 players");
        assertEq(players[0], player1, "First player should be player1");
        assertEq(players[1], player2, "Second player should be player2");
    }
}
