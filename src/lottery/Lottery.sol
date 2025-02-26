// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/Bitmask.sol"; // Assuming Bitmask is a separate library

/**
 * @title Lottery (Optimized Ticket Claiming & Checking)
 * @author Your Name
 * @notice Players can check if a ticket has matching numbers and claim prizes.
 * @dev Uses an external Bitmask library for encoding, decoding & number matching.
 */
contract Lottery {
    uint256 public currentLotteryId;

    struct LotteryGame {
        uint256 lotteryId;
        uint256 maxNumber;
        uint256 numbersToPick;
        uint256 winningBitmask;
        bool isActive;
        mapping(uint256 => address[]) ticketOwners; // Maps bitmask → Players who picked that set
        mapping(bytes32 => bool) claimedTickets; // Prevents double claiming
    }

    mapping(uint256 => LotteryGame) public lotteries; // Stores all lotteries
    mapping(address => mapping(uint256 => uint256[])) public playerTickets; // Tracks player tickets per gameId

    event LotteryCreated(
        uint256 indexed lotteryId,
        uint256 maxNumber,
        uint256 numbersToPick
    );
    event TicketPurchased(
        address indexed player,
        uint256 indexed lotteryId,
        uint256 numberBitmask
    );
    event MultipleTicketsPurchased(
        address indexed player,
        uint256 indexed lotteryId,
        uint256 ticketCount
    );
    event WinningNumbersSet(uint256 indexed lotteryId, uint256 numberBitmask);
    event PrizeClaimed(
        address indexed player,
        uint256 indexed lotteryId,
        uint256 ticketId
    );

    modifier lotteryActive(uint256 lotteryId) {
        require(lotteries[lotteryId].isActive, "Lottery is not active");
        _;
    }

    /**
     * @notice Checks if a specific ticket has matching numbers.
     * @dev Takes `lotteryId`, `playerAddress`, and `ticketId` to validate winnings.
     * @return matchingCount Number of matching numbers.
     */
    function hasMatching(
        uint256 lotteryId,
        address player,
        uint256 playerTicketId
    ) public view returns (uint256 matchingCount) {
        require(
            playerTickets[player][lotteryId].length > playerTicketId,
            "Lottery: Invalid ticket ID"
        );

        uint256 ticketBitmask = playerTickets[player][lotteryId][
            playerTicketId
        ];
        uint256 winningMask = lotteries[lotteryId].winningBitmask;

        // Calculate matching numbers
        matchingCount = Bitmask.countMatchingBits(
            ticketBitmask,
            winningMask,
            lotteries[lotteryId].maxNumber
        );
    }

    /**
     * @notice Internal function to mark a ticket as claimed.
     * @dev Ensures the same ticket cannot be claimed multiple times.
     */
    function setClaimedPrize(
        uint256 lotteryId,
        address player,
        uint256 ticketId
    ) internal {
        require(
            playerTickets[player][lotteryId].length > ticketId,
            "Lottery: Invalid ticket ID"
        );

        uint256 ticketBitmask = playerTickets[player][lotteryId][ticketId];

        // Prevent duplicate claims
        bytes32 ticketHash = keccak256(
            abi.encodePacked(player, lotteryId, ticketBitmask)
        );
        require(
            !lotteries[lotteryId].claimedTickets[ticketHash],
            "Lottery: Prize already claimed"
        );

        lotteries[lotteryId].claimedTickets[ticketHash] = true;
        emit PrizeClaimed(player, lotteryId, ticketId);
    }

    /**
     * @notice Returns the player's ticket selections for a specific lottery.
     * @dev Uses `Bitmask.decode()` to return readable number selections.
     */
    function getPlayerTickets(
        address player,
        uint256 lotteryId
    ) public view returns (uint256[][] memory) {
        uint256[] storage bitmasks = playerTickets[player][lotteryId];
        uint256[][] memory tickets = new uint256[][](bitmasks.length);

        for (uint256 i = 0; i < bitmasks.length; i++) {
            tickets[i] = Bitmask.decode(
                bitmasks[i],
                lotteries[lotteryId].maxNumber
            );
        }

        return tickets;
    }

    /**
     * @notice Internal function that processes ticket purchases.
     * @dev Called by `buyTicket()` and `buyMultipleTickets()` to reduce redundant code.
     */
    function processTicketPurchase(
        uint256 lotteryId,
        uint256[] memory numbers,
        address player
    ) internal returns (bool added) {
        LotteryGame storage lottery = lotteries[lotteryId];
        require(
            numbers.length == lottery.numbersToPick,
            "Lottery: Need to pick the correct amount of Numbers."
        );
        uint256 bitmask = Bitmask.encode(numbers);
        // Store player under the bitmask mapping
        lottery.ticketOwners[bitmask].push(player);

        // Store player's numbers for this lottery
        playerTickets[player][lotteryId].push(bitmask);
        added = true;
    }

    /**
     * @notice Returns the winning numbers for a specific lottery as an array.
     * @dev Uses `Bitmask.decode()` to convert the stored bitmask into a number array.
     */
    function getWinningNumbers(
        uint256 lotteryId
    ) public view returns (uint256[] memory) {
        return
            Bitmask.decode(
                lotteries[lotteryId].winningBitmask,
                lotteries[lotteryId].maxNumber
            );
    }

    /**
     * @notice Returns the players who picked a given combination of numbers in a lottery.
     * @dev The input is a decoded array of numbers instead of a raw bitmask.
     */
    function getPlayersForNumbers(
        uint256 lotteryId,
        uint256[] memory numbers
    ) public view virtual returns (address[] memory) {
        uint256 bitmask = Bitmask.encode(numbers);
        return lotteries[lotteryId].ticketOwners[bitmask];
    }

    /**
     * @notice Internal function to create a lottery.
     * @dev Must be called within derived contracts or automated systems.
     */
    function createLottery(uint256 maxNumber, uint256 numbersToPick) internal {
        require(
            0 < numbersToPick && numbersToPick < maxNumber && maxNumber < 256,
            "Lottery: Creation parameters Out of range"
        );
        currentLotteryId++;
        LotteryGame storage newLottery = lotteries[currentLotteryId];
        newLottery.lotteryId = currentLotteryId;
        newLottery.maxNumber = maxNumber;
        newLottery.numbersToPick = numbersToPick;
        newLottery.isActive = true;

        emit LotteryCreated(currentLotteryId, maxNumber, numbersToPick);
    }

    /**
     * @notice Internal function to set the winning numbers.
     * @dev Must be called within derived contracts or automated systems.
     */
    function setWinningNumbers(
        uint256 lotteryId,
        uint256[] memory numbers
    ) internal {
        require(
            numbers.length == lotteries[lotteryId].numbersToPick,
            "Lottery: Invalid winning numbers"
        );
        require(lotteries[lotteryId].isActive, "Lottery: Lottery not active.");

        lotteries[lotteryId].winningBitmask = Bitmask.encode(numbers);
        lotteries[lotteryId].isActive = false;

        emit WinningNumbersSet(lotteryId, lotteries[lotteryId].winningBitmask);
    }
}
