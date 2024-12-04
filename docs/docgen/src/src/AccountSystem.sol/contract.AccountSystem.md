# AccountSystem
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/747a9f879e52c48fe525c83a0a51a637e87ccd6e/src/AccountSystem.sol)

Manages player accounts for The Degen Casino. Can be deployed permissionlessly. Any number of these contracts
can be deployed to a chain. There can be multiple independent instances of this contract on a chain.


## State Variables
### accounts

```solidity
mapping(address => DegenCasinoAccount) public accounts;
```


### systemVersion

```solidity
string public constant systemVersion = AccountSystemVersion;
```


### accountVersion

```solidity
string public constant accountVersion = AccountVersion;
```


## Functions
### constructor


```solidity
constructor();
```

### calculateAccountAddress


```solidity
function calculateAccountAddress(address player) public view returns (address result);
```

### createAccount

Creates an account for the given player assuming that one doesn't already exist.


```solidity
function createAccount(address player) public returns (address, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`player`|`address`|The player for whom the account is being created.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|account The address of the created account.|
|`<none>`|`bool`|created A boolean indicating whether the account was created (true) or whether it already existed (false).|


## Events
### AccountSystemCreated

```solidity
event AccountSystemCreated(string indexed systemVersion, string indexed accountVersion);
```

### AccountCreated

```solidity
event AccountCreated(address account, address indexed player, string indexed accountVersion);
```

