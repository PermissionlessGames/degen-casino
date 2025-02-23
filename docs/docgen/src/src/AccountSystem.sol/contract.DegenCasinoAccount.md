# DegenCasinoAccount
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/a6696f00c13f9274ae713de85e5b1212b5977800/src/AccountSystem.sol)

**Inherits:**
EIP712

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


### lastRequest

```solidity
uint256 public lastRequest;
```


## Functions
### constructor


```solidity
constructor(address _player) EIP712("DegenCasinoAccount", AccountVersion);
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

### executorTermsHash

Computes the EIP712 hash of executor terms


```solidity
function executorTermsHash(ExecutorTerms memory terms) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`terms`|`ExecutorTerms`|The executor terms to hash|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The EIP712 hash of the terms|


### actionHash

Computes the EIP712 hash of a game action


```solidity
function actionHash(Action memory action) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action to hash|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The EIP712 hash of the action|


### sessionHash

Computes the EIP712 hash of a session


```solidity
function sessionHash(address executor, uint256 sessionID, uint256 expiration) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`executor`|`address`|The executor authorized by the player|
|`sessionID`|`uint256`|The session ID|
|`expiration`|`uint256`|The expiration timestamp of the session|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The EIP712 hash of the session|


### play

Executes a game action with executor compensation

*Verifies signatures, executes the action, and pays the executor based on profit*


```solidity
function play(
    Action memory action,
    ExecutorTerms memory terms,
    bytes memory playerActionSignature,
    bytes memory playerTermsSignature
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The game action to execute|
|`terms`|`ExecutorTerms`|The executor's compensation terms|
|`playerActionSignature`|`bytes`|The player's signature for the action|
|`playerTermsSignature`|`bytes`|The player's signature for the executor terms|


### _play

Internal function to execute the game action and pay executor rewards


```solidity
function _play(Action memory action, ExecutorTerms memory terms) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The game action to execute|
|`terms`|`ExecutorTerms`|The executor's compensation terms|


### playInSession

Executes a game action with executor compensation in a session

*Verifies session and terms signatures, executes the action*


```solidity
function playInSession(
    Action memory action,
    ExecutorTerms memory terms,
    uint256 sessionID,
    uint256 expiration,
    bytes memory playerSessionSignature,
    bytes memory playerTermsSignature
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The game action to execute|
|`terms`|`ExecutorTerms`|The executor's compensation terms|
|`sessionID`|`uint256`|The session ID|
|`expiration`|`uint256`|The expiration timestamp of the session|
|`playerSessionSignature`|`bytes`|The player's signature for the session|
|`playerTermsSignature`|`bytes`|The player's signature for the executor terms|


## Errors
### Unauthorized

```solidity
error Unauthorized();
```

### Unsuccessful

```solidity
error Unsuccessful();
```

### MismatchedArrayLengths

```solidity
error MismatchedArrayLengths();
```

### RequestTooLow

```solidity
error RequestTooLow();
```

### InvalidPlayerActionSignature

```solidity
error InvalidPlayerActionSignature();
```

### InvalidPlayerTermsSignature

```solidity
error InvalidPlayerTermsSignature();
```

### InvalidSessionSignature

```solidity
error InvalidSessionSignature();
```

### SessionExpired

```solidity
error SessionExpired();
```

### FailedToSendReward

```solidity
error FailedToSendReward();
```

### ActionFailed

```solidity
error ActionFailed();
```

