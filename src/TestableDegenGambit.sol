// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

    function reverseEntropy(
        uint256 left,
        uint256 center,
        uint256 right,
        address player
    ) public {
        //TODO: calculate entorpy for specific positions
    }

    function setDailyStreak(uint256 dailyStreak, address player) public {
        LastStreakDay[player] = dailyStreak;
    }

    function setWeeklyStreak(uint256 weeklyStreak, address player) public {
        LastStreakWeek[player] = weeklyStreak;
    }
}
