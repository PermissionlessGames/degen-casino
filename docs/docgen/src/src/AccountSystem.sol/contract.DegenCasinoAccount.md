# DegenCasinoAccount
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/a5de5916419fddea1366432734c7e583b8020846/src/AccountSystem.sol)

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

Withdraw multiple different tokens (native or ERC20) from the DegenCasinoAccount in a single transaction.


```solidity
function withdraw(address[] memory tokenAddresses, uint256[] memory amounts) public;
```

### drain

Used to drain native tokens or ERC20 tokens from the DegenCasinoAccount.


```solidity
function drain(address[] memory tokenAddresses) public;
```

## Errors
### Unauthorized

```solidity
error Unauthorized();
```

