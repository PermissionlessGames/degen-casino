# BlockInspector
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/8f57908c9fa7257d5b12b8ce17569a15ef42890a/src/BlockInspector.sol)

*This contract is for debugging purposes related to blockhashes and block nunbers on Arbitrum chains.*


## Functions
### blockNumbers


```solidity
function blockNumbers() external view returns (uint256, uint256);
```

### hash


```solidity
function hash(uint256 number) external view returns (bytes32);
```

### arbBlockHash


```solidity
function arbBlockHash(uint256 number) external view returns (bytes32);
```

