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
}
