// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/libraries/Combinatorics.sol"; // Adjust path if needed

/**
 * @title Combinatorics Library
 * @author Permissionless Games, ChatGPT
 */

contract CombinatoricsTest is Test {
    function testFactorial() public pure {
        assertEq(
            Combinatorics.factorial(5),
            120,
            "Factorial of 5 should be 120"
        );
        assertEq(Combinatorics.factorial(0), 1, "Factorial of 0 should be 1");
        assertEq(Combinatorics.factorial(1), 1, "Factorial of 1 should be 1");
        assertEq(Combinatorics.factorial(3), 6, "Factorial of 3 should be 6");
    }

    function testCombination() public pure {
        assertEq(Combinatorics.combination(5, 3), 10, "C(5,3) should be 10");
        assertEq(
            Combinatorics.combination(10, 5),
            252,
            "C(10,5) should be 252"
        );
        assertEq(Combinatorics.combination(6, 2), 15, "C(6,2) should be 15");
    }

    function testPermutation() public pure {
        assertEq(Combinatorics.permutation(5, 3), 60, "P(5,3) should be 60");
        assertEq(
            Combinatorics.permutation(10, 5),
            30240,
            "P(10,5) should be 30240"
        );
        assertEq(Combinatorics.permutation(6, 2), 30, "P(6,2) should be 30");
    }

    function testInvalidCombination() public {
        vm.expectRevert("COMBINATORICS: n must be greater than r");
        Combinatorics.combination(3, 5);
        vm.expectRevert("COMBINATORICS: r must be greater than 0");
        Combinatorics.combination(3, 0);
    }

    function testInvalidPermutation() public {
        vm.expectRevert("COMBINATORICS: n must be greater than r");
        Combinatorics.permutation(3, 5);
        vm.expectRevert("COMBINATORICS: r must be greater than 0");
        Combinatorics.permutation(3, 0);
    }

    function testValidOddsOfMatching() public pure {
        uint256 result = Combinatorics.oddsOfMatching(10, 4, 2);
        assertEq(result, 90, "Odds of match (10, 4, 2) should be 90");
    }

    function testInvalidOddsOfMatching() public {
        // This call should revert. In your test framework, you would capture the revert.
        vm.expectRevert("COMBINATORICS: r must be greater than 0");
        Combinatorics.oddsOfMatching(10, 5, 0);
        vm.expectRevert("COMBINATORICS: Improper arguments for matching");
        Combinatorics.oddsOfMatching(10, 6, 0);
    }

    function testKGreaterThanR() public {
        vm.expectRevert();
        Combinatorics.oddsOfMatching(10, 4, 5);
    }

    function testOverFlowFactorialForOver57() public {
        Combinatorics.factorial(57);
        vm.expectRevert(
            "Combinatorics: Factorial UpperBounds reached must be less then 57"
        );
        Combinatorics.factorial(58);
        vm.expectRevert(
            "Combinatorics: Factorial UpperBounds reached must be less then 57"
        );
        Combinatorics.factorial(100);
    }

    function testChoose5UpperBoundaries() public {
        uint256 results = Combinatorics.combination(2586638741762876, 5);
        assertEq(
            results,
            964934076977634413059720290138078624491229918748974612800501656983313064200,
            "Combintation of (2586638741762876, 5) should be 964,934,076,977,634,413,059,720,290,138,078,624,491,229,918,748,974,612,800,501,656,983,313,064,200"
        );
        vm.expectRevert();
        Combinatorics.combination(2586638741762877, 5);

        results = Combinatorics.permutation(2586638741762876, 5);
        assertEq(
            results,
            115792089237316129567166434816569434938947590249876953536060198837997567704000,
            "Permutation of (2586638741762876, 5) should be 115,792,089,237,316,129,567,166,434,816,569,434,938,947,590,249,876,953,536,060,198,837,997,567,704,000"
        );
        vm.expectRevert();
        Combinatorics.permutation(2586638741762877, 5);
    }
}
