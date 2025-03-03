# Bitmask
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/ef1d4f0f9ff01dcc397e9ddcaef29b2222eb408d/src/libraries/Bitmask.sol)


## Functions
### encode

Encodes an array of numbers into a single bitmask.


```solidity
function encode(uint256[] memory numbers) internal pure returns (uint256 bitmask);
```

### decode

Decodes a bitmask into an array of numbers.


```solidity
function decode(uint256 bitmask, uint256 maxNumber) internal pure returns (uint256[] memory numbers);
```

### countMatchingBits

Counts the number of matching bits between two bitmasks.


```solidity
function countMatchingBits(uint256 bitmask1, uint256 bitmask2, uint256 maxRange) internal pure returns (uint256);
```

