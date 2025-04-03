// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Combinatorics Library
 * @author Permissionless Games
 * @notice This library provides efficient implementations of combinatorial functions such as factorial,
 * permutations, and combinations for use in smart contracts.
 * @dev Optimized for gas efficiency, with algebraic simplifications and sequential product calculations.
 */

library Combinatorics {
    /**
     * @notice Calculates the factorial of a number.
     * @dev The largest factorial that can be calculated with uint256 is 57, anything larger will revert.
     * @param n The number to calculate the factorial of.
     * @return nFactorial The factorial of the number.
     */
    function factorial(uint256 n) internal pure returns (uint256 nFactorial) {
        require(
            n < 58,
            "Combinatorics: Factorial UpperBounds reached must be less then 57"
        );

        nFactorial = sequentialProduct(1, n);
    }

    /**
     * @notice Calculates the sequential product of a range of numbers.
     * @dev This function is used to calculate the product of a range of numbers.
     * @param from The starting number of the range.
     * @param to The ending number of the range.
     * @return product The product of the numbers in the range.
     */
    function sequentialProduct(
        uint256 from,
        uint256 to
    ) internal pure returns (uint256 product) {
        product = 1;
        //if from is 0 then it'll still return 1!
        from = from == 0 ? 1 : from;
        for (uint256 i = from; i <= to; i++) {
            if (type(uint256).max / product < i) {
                revert("Combinatorics: Product overflow");
            }
            product = product * i;
        }
    }

    /**
     * @notice Calculates the number of combinations of n items taken r at a time.
     * @dev This function is used to calculate the number of combinations of n items taken r at a time.
     * @param n The number of items.
     * @param r The number of items to take.
     * @return odds The number of combinations of n items taken r at a time.
     */
    function combination(
        uint256 n,
        uint256 r
    ) internal pure returns (uint256 odds) {
        //n!/(r!(n-r)!)
        require(n > r, "COMBINATORICS: n must be greater than r");
        require(r > 0, "COMBINATORICS: r must be greater than 0");
        uint256 p = (n - r) + 1;
        //n!/(n-r)! saves minor gas through algebra it'll calculate from (n-r+1) -> n
        //C(10,5) = 10!/5!5! = (6*7*8*9*10)/5! = 30240/120 = 252
        odds = sequentialProduct(p, n);
        //if r is 1 then it'll still return 1!
        odds = odds / sequentialProduct(2, r);
    }

    /**
     * @notice Calculates the number of permutations of n items taken r at a time.
     * @dev This function is used to calculate the number of permutations of n items taken r at a time.
     * @param n The number of items.
     * @param r The number of items to take.
     * @return odds The number of permutations of n items taken r at a time.
     */
    function permutation(
        uint256 n,
        uint256 r
    ) internal pure returns (uint256 odds) {
        require(n > r, "COMBINATORICS: n must be greater than r");
        require(r > 0, "COMBINATORICS: r must be greater than 0");
        //P(n,r) = n!/(n-r)!
        odds = sequentialProduct(n - r + 1, n);
    }

    /**
     * @notice Calculates the number of Combinations of n items taken r at a time.
     * @dev This function is used to calculate the number of Combinations of n items taken r at a time.
     * @param n The number of items.
     * @param r The number of items to take.
     * @param k The number of items to match.
     * @return odds The number of Combinations of n items taken r at a time.
     */
    function oddsOfMatching(
        uint256 n,
        uint256 r,
        uint256 k
    ) internal pure returns (uint256 odds) {
        require(
            k <= r && n > r,
            "COMBINATORICS: Improper arguments for matching"
        );
        require(
            n - r >= r - k,
            "COMBINATORICS: Improper arguments for matching"
        );

        uint256 crk = combination(r, k);
        uint256 cn_rr_k = combination(n - r, r - k);
        odds = crk * cn_rr_k;
    }
}
