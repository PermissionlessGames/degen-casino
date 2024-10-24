# BlockInspector
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/9b00df6b1597b03ed63ef7c7d1f49ac2945b0480/src/BlockInspector.sol)

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

