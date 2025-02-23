# AccountSystem7702
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/a6696f00c13f9274ae713de85e5b1212b5977800/src/AccountSystem7702.sol)

**Inherits:**
EIP712


## State Variables
### nonce

```solidity
uint256 public nonce;
```


### locked

```solidity
bool public locked;
```


## Functions
### nonReentrant

================================ MODIFIERS ================================


```solidity
modifier nonReentrant();
```

### constructor


```solidity
constructor() EIP712("AccountSystem7702", "1");
```

### execute

================================ PUBLIC FUNCTIONS ================================

Execute a batch of actions


```solidity
function execute(Action[] memory actions, bytes[] memory signatures) public nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`actions`|`Action[]`|The actions to execute|
|`signatures`|`bytes[]`|The signatures of the actions|


### _processExecutorTerms

================================ INTERNAL FUNCTIONS ================================

Process the executor terms


```solidity
function _processExecutorTerms(Action memory action, uint256 initialBalance) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action|
|`initialBalance`|`uint256`|The initial balance of the token|


### _execute

Execute an action


```solidity
function _execute(Action memory action, bytes memory signature) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action to execute|
|`signature`|`bytes`|The signature of the action|


### _processExecutorTermsWithBasisPoints

Process the executor terms with basis points


```solidity
function _processExecutorTermsWithBasisPoints(Action memory action, uint256 initialBalance) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action|
|`initialBalance`|`uint256`|The initial balance of the token|


### _processExecutorTermsWithAmounts

Process the executor terms with amounts


```solidity
function _processExecutorTermsWithAmounts(Action memory action) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action|


### _transfer

Transfer a token to the executor


```solidity
function _transfer(address token, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token to transfer|
|`amount`|`uint256`|The amount to transfer|


### getBalance

================================ GETTERS ================================

Get the balance of a token


```solidity
function getBalance(address token) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token to get the balance of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The balance of the token|


### hashAction

Computes the EIP712 hash of a game action


```solidity
function hashAction(Action memory action) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action to hash|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The EIP712 hash of the action|


## Events
### ActionExecuted

```solidity
event ActionExecuted(Action action, address executor);
```

### NonceUpdated

```solidity
event NonceUpdated(uint256 newNonce);
```

## Errors
### InvalidSignature

```solidity
error InvalidSignature();
```

### ActionExpired

```solidity
error ActionExpired();
```

### InvalidNonce

```solidity
error InvalidNonce();
```

### InvalidBasisPoints

```solidity
error InvalidBasisPoints();
```

### ReentrancyGuard

```solidity
error ReentrancyGuard();
```

