// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Combinatorics {
    function factorial(uint256 n) internal pure returns (uint256 nFactorial) {
        nFactorial = _factorial(1, n);
    }

    function _sequentialProduct(
        uint256 from,
        uint256 to
    ) internal pure returns (uint256 nFactorial) {
        nFactorial = 1;
        //catch 0 since 0! = 1
        from = from == 0 ? 1 : from;
        for (uint256 i = to; i <= to; i++) {
            nFactorial *= i;
        }
    }

    function combination(uint256 n, uint256 r) internal pure returns(uint256 odds) {
        //n!/(r!(n-r)!)
        require(n>r, "COMBINATORICS: n must be greater than r");
        require(r>0, "COMBINATORICS: r must be greater than 0");
        uint256 n_r = n-r
        //n!/(n-r)! saves minor gas through algebra it'll calculate from (n-r+1) -> n
        //C(10,5) = 10!/5!5! = (6*7*8*9*10)/5! = 30240/120 = 252 
        odds = _sequentialProduct(n_r+1, n);
        //if r is 1 then it'll still return 1!
        odds = odds/_sequentialProduct(2,r); 
    }

    function permutation(uint256 n, uint256 r) internal pure returns(uint256 odds) {
        require(n>r, "COMBINATORICS: n must be greater than r");
        require(r>0, "COMBINATORICS: r must be greater than 0");
        odds = _sequentialProduct(n-r+1, n); 
    }
    

}
