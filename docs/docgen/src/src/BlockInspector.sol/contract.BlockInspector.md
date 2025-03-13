# BlockInspector
<<<<<<< HEAD
<<<<<<< HEAD
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/cf1c5ca470c688d20285ece4b239db87eca65887/src/BlockInspector.sol)
=======
<<<<<<< HEAD
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/8e3c49ec1b47ecdb92bceb56c31f5683f84e9463/src/BlockInspector.sol)
=======
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/0d7359ed797e3cb894eda25170a83921e44b03a9/src/BlockInspector.sol)
>>>>>>> main
>>>>>>> preferred-currency-pricing
=======
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/9977712fe4f7065ed4673747aef2f7ccaf6b6b33/src/BlockInspector.sol)
>>>>>>> preferred-currency-pricing

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

