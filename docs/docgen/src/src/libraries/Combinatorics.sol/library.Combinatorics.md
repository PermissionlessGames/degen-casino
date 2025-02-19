# Combinatorics
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/b437b3f04a3d41a5542982413209a5db38bd1fd9/src/libraries/Combinatorics.sol)

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

