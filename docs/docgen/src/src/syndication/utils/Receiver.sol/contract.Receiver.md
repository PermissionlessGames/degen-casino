# Receiver
[Git Source](https://github.com//PermissionlessGames/degen-casino/blob/12976e9fd5c84ac10effba9d0fe44362cdc76a38/src/syndication/utils/Receiver.sol)


## State Variables
### owner

```solidity
address public owner;
```


### launcher

```solidity
address immutable launcher;
```


### _erc20

```solidity
address immutable _erc20;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner();
```

### setOwner


```solidity
function setOwner(address newOwner) external onlyOwner;
```

### constructor


```solidity
constructor(address erc20, address _owner);
```

### receive

Allows the contract to receive the native token on its blockchain.


```solidity
receive() external payable;
```

### handleRewards


```solidity
function handleRewards(address prizeReceiver, address otherReceiver)
    external
    virtual
    onlyOwner
    returns (uint256 amountPrize, uint256 amountOther);
```

### _nativeTransfer


```solidity
function _nativeTransfer(address to) internal returns (uint256 amount);
```

### _erc20Transfer


```solidity
function _erc20Transfer(address to) internal returns (uint256 amount);
```

## Events
### NewOwner

```solidity
event NewOwner(address _owner);
```

