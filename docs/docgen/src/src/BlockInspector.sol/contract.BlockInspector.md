# BlockInspector
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/d5d1c3d9566055d3e4541f15fb63115f6b048546/src/BlockInspector.sol)

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

