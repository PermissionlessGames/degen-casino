# BlockInspector
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/41f4377073e5611a65eba8117337a6df53e8264d/src/BlockInspector.sol)

*This contract is for debugging purposes related to blockhashes and block nunbers on Arbitrum chains.*


## State Variables
### BlockhashStore

```solidity
bytes32 public BlockhashStore;
```


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

### writeCurrentBlockHash


```solidity
function writeCurrentBlockHash() external;
```

