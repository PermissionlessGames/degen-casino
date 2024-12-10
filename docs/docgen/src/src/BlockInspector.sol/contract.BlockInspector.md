# BlockInspector
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/e86eb68c6bd068a7263660f5e592ef4b7868e403/src/BlockInspector.sol)

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

