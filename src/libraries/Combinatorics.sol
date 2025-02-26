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
    // Largest Factorial possible with uint256 is 57, anything larger will revert
    function factorial(uint256 n) internal pure returns (uint256 nFactorial) {
        require(
            n < 58,
            "Combinatorics: Factorial UpperBounds reached must be less then 57"
        );
        nFactorial = sequentialProduct(1, n);
    }

    function sequentialProduct(
        uint256 from,
        uint256 to
    ) internal pure returns (uint256 nFactorial) {
        nFactorial = 1;
        from = from == 0 ? 1 : from;
        for (uint256 i = from; i <= to; i++) {
            nFactorial = i * nFactorial;
        }
    }

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

    function permutation(
        uint256 n,
        uint256 r
    ) internal pure returns (uint256 odds) {
        require(n > r, "COMBINATORICS: n must be greater than r");
        require(r > 0, "COMBINATORICS: r must be greater than 0");
        odds = sequentialProduct(n - r + 1, n);
    }

    function oddsOfMatching(
        uint256 n,
        uint256 r,
        uint256 k
    ) internal pure returns (uint256 odds) {
        require(
            n - r >= r - k,
            "COMBINATORICS: Improper arguments for matching"
        );
        uint256 crk = combination(r, k);
        uint256 cn_rr_k = combination(n - r, r - k);
        odds = crk * cn_rr_k;
    }
}
