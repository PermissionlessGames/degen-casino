// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DegenGambit} from "../DegenGambit.sol";

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

    function mintGambit(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function setDailyStreak(uint256 dailyStreak, address player) public {
        LastStreakDay[player] = dailyStreak;
    }

    function setWeeklyStreak(uint256 weeklyStreak, address player) public {
        LastStreakWeek[player] = weeklyStreak;
    }

    function version() external pure override returns (string memory) {
        return "1 - debuggable";
    }

    function generateEntropyForUnmodifiedReelOutcome(
        uint256 leftOutcome,
        uint256 centerOutcome,
        uint256 rightOutcome
    ) public view returns (uint256) {
        // Ensure the outcome indices are within the valid range (0-18)
        require(leftOutcome < 19, "Invalid left outcome");
        require(centerOutcome < 19, "Invalid center outcome");
        require(rightOutcome < 19, "Invalid right outcome");

        // Get the valid range for the left outcome
        uint256 leftSample = getSampleForOutcome(
            leftOutcome,
            UnmodifiedLeftReel
        );

        // Get the valid range for the center outcome
        uint256 centerSample = getSampleForOutcome(
            centerOutcome,
            UnmodifiedCenterReel
        );

        // Get the valid range for the right outcome
        uint256 rightSample = getSampleForOutcome(
            rightOutcome,
            UnmodifiedRightReel
        );

        // Combine the samples into an entropy value
        uint256 entropy = (leftSample << 60) |
            (centerSample << 30) |
            rightSample;

        return entropy;
    }

    function setEntropyFromOutcomes(
        uint256 left,
        uint256 center,
        uint256 right,
        address player,
        bool boost
    ) public {
        uint256 entropy = boost
            ? generateEntropyForImprovedReelOutcome(left, center, right)
            : generateEntropyForUnmodifiedReelOutcome(left, center, right);
        EntropyForPlayer[player] = entropy;
    }

    function generateEntropyForImprovedReelOutcome(
        uint256 leftOutcome,
        uint256 centerOutcome,
        uint256 rightOutcome
    ) public view returns (uint256) {
        // Ensure the outcome indices are within the valid range (0-18)
        require(leftOutcome < 19, "Invalid left outcome");
        require(centerOutcome < 19, "Invalid center outcome");
        require(rightOutcome < 19, "Invalid right outcome");

        // Get the valid range for the left outcome
        uint256 leftSample = getSampleForOutcome(leftOutcome, ImprovedLeftReel);

        // Get the valid range for the center outcome
        uint256 centerSample = getSampleForOutcome(
            centerOutcome,
            ImprovedCenterReel
        );

        // Get the valid range for the right outcome
        uint256 rightSample = getSampleForOutcome(
            rightOutcome,
            ImprovedRightReel
        );

        // Combine the samples into an entropy value
        uint256 entropy = (leftSample << 60) |
            (centerSample << 30) |
            rightSample;

        return entropy;
    }

    function getSampleForOutcome(
        uint256 outcome,
        uint256[19] storage reel
    ) internal view returns (uint256) {
        uint256 sample = outcome == 0 ? 0 : reel[outcome - 1]; // The minimum sample value for this outcome

        return sample;
    }

    function setBlocksToAct(uint256 newBlocksToAct) external {
        BlocksToAct = newBlocksToAct;
    }

    function setLastSpinBoosted(address player, bool boost) external {
        LastSpinBoosted[player] = boost;
    }

    function setLastSpinBlock(address player, uint256 blockNumber) external {
        LastSpinBlock[player] = blockNumber;
    }

    function setCostToSpin(uint256 newCostToSpin) external {
        CostToSpin = newCostToSpin;
    }

    function setCostToRespin(uint256 newCostToRespin) external {
        CostToRespin = newCostToRespin;
    }
}
