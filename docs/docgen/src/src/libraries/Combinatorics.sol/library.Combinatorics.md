# Combinatorics
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/ef1d4f0f9ff01dcc397e9ddcaef29b2222eb408d/src/libraries/Combinatorics.sol)

**Author:**
Permissionless Games

This library provides efficient implementations of combinatorial functions such as factorial,
permutations, and combinations for use in smart contracts.

*Optimized for gas efficiency, with algebraic simplifications and sequential product calculations.*


## Functions
### factorial


```solidity
function factorial(uint256 n) internal pure returns (uint256 nFactorial);
```

### sequentialProduct


```solidity
function sequentialProduct(uint256 from, uint256 to) internal pure returns (uint256 nFactorial);
```

### combination


```solidity
function combination(uint256 n, uint256 r) internal pure returns (uint256 odds);
```

### permutation


```solidity
function permutation(uint256 n, uint256 r) internal pure returns (uint256 odds);
```

### oddsOfMatching


```solidity
function oddsOfMatching(uint256 n, uint256 r, uint256 k) internal pure returns (uint256 odds);
```

