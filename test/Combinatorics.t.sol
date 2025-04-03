// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/libraries/Combinatorics.sol";

contract CombinatoricsWrapper {
    function factorial(uint256 n) external pure returns (uint256) {
        return Combinatorics.factorial(n);
    }

    function combination(uint256 n, uint256 r) external pure returns (uint256) {
        return Combinatorics.combination(n, r);
    }

    function permutation(uint256 n, uint256 r) external pure returns (uint256) {
        return Combinatorics.permutation(n, r);
    }

    function oddsOfMatching(
        uint256 n,
        uint256 r,
        uint256 k
    ) external pure returns (uint256) {
        return Combinatorics.oddsOfMatching(n, r, k);
    }
}

contract CombinatoricsTest is Test {
    CombinatoricsWrapper public wrapper;

    function setUp() public {
        wrapper = new CombinatoricsWrapper();
    }

    function testFactorial() public view {
        assertEq(wrapper.factorial(5), 120, "Factorial of 5 should be 120");
        assertEq(wrapper.factorial(0), 1, "Factorial of 0 should be 1");
        assertEq(wrapper.factorial(1), 1, "Factorial of 1 should be 1");
        assertEq(wrapper.factorial(3), 6, "Factorial of 3 should be 6");
    }

    function testCombination() public view {
        assertEq(wrapper.combination(5, 3), 10, "C(5,3) should be 10");
        assertEq(wrapper.combination(10, 5), 252, "C(10,5) should be 252");
        assertEq(wrapper.combination(6, 2), 15, "C(6,2) should be 15");
    }

    function testPermutation() public view {
        assertEq(wrapper.permutation(5, 3), 60, "P(5,3) should be 60");
        assertEq(wrapper.permutation(10, 5), 30240, "P(10,5) should be 30240");
        assertEq(wrapper.permutation(6, 2), 30, "P(6,2) should be 30");
    }

    function testInvalidCombinationNLessThanR() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinatorics.NLessThanR.selector, 3, 5)
        );
        wrapper.combination(3, 5);
    }

    function testCombinationRIsZero() public view {
        assertEq(wrapper.combination(3, 0), 1, "C(3,0) should be 1");
    }

    function testInvalidPermutation() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinatorics.NLessThanR.selector, 3, 5)
        );
        wrapper.permutation(3, 5);
    }

    function testValidOddsOfMatching() public view {
        uint256 result = wrapper.oddsOfMatching(10, 4, 2);
        assertEq(result, 90, "Odds of match (10, 4, 2) should be 90");
    }

    function testInvalidOddsOfMatching() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.ImproperArgumentsForMatching.selector,
                10,
                6,
                0
            )
        );
        wrapper.oddsOfMatching(10, 6, 0);
    }

    function testKGreaterThanR() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.ImproperArgumentsForMatching.selector,
                10,
                4,
                5
            )
        );
        wrapper.oddsOfMatching(10, 4, 5);
    }

    function testOverFlowFactorialForOver57() public {
        wrapper.factorial(57);
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.FactorialUpperBoundsReached.selector,
                58
            )
        );
        wrapper.factorial(58);
    }

    function testChoose5UpperBoundaries() public {
        uint256 results = wrapper.combination(2586638741762876, 5);
        assertEq(
            results,
            964934076977634413059720290138078624491229918748974612800501656983313064200,
            "Combintation of (2586638741762876, 5) should be 964,934,076,977,634,413,059,720,290,138,078,624,491,229,918,748,974,612,800,501,656,983,313,064,200"
        );

        results = wrapper.permutation(2586638741762876, 5);
        assertEq(
            results,
            115792089237316129567166434816569434938947590249876953536060198837997567704000,
            "Permutation of (2586638741762876, 5) should be 115,792,089,237,316,129,567,166,434,816,569,434,938,947,590,249,876,953,536,060,198,837,997,567,704,000"
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.ProductOverflow.selector,
                2586638741762873,
                2586638741762877,
                2586638741762877
            )
        );
        wrapper.permutation(2586638741762877, 5);
    }

    function testChoose5CombinationUpperBoundariesShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.ProductOverflow.selector,
                2586638741762873,
                2586638741762877,
                2586638741762877
            )
        );
        wrapper.combination(2586638741762877, 5);
    }

    function testChoose5PermutationUpperBoundariesShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinatorics.ProductOverflow.selector,
                2586638741762873,
                2586638741762877,
                2586638741762877
            )
        );
        wrapper.permutation(2586638741762877, 5);
    }
}
