# DegenCasinoAccount
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/3a1795ece2870392267c2c2148f1b9be907fcbbd/src/AccountSystem.sol)

Player smart accounts for The Degen Casino.


## State Variables
### player

```solidity
address public player;
```


### accountVersion

```solidity
string public constant accountVersion = AccountVersion;
```


## Functions
### constructor


```solidity
constructor(address _player);
```

### receive

Used to deposit native tokens to the DegenCasinoAccount.


```solidity
receive() external payable;
```

### withdraw

Used to withdraw native tokens or ERC20 tokens from the DegenCasinoAccount.


```solidity
function withdraw(address tokenAddress, uint256 amount) public;
```

### drain

Used to drain native tokens or ERC20 tokens from the DegenCasinoAccount.


```solidity
function drain(address tokenAddress) public;
```

## Errors
### Unauthorized

```solidity
error Unauthorized();
```

