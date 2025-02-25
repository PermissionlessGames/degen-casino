# AccountSystem7702Alt
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/9c6d5d70b9c8f85602727ed0d0bb7e05794c273b/src/AccountSystem7702Alt.sol)


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
constructor();
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
function _processExecutorTerms(ExecutionTerms[] memory executionTerms, uint256[] memory initialBalances) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`executionTerms`|`ExecutionTerms[]`|The execution terms|
|`initialBalances`|`uint256[]`|The initial balances of the tokens|


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
function _processExecutorTermsWithBasisPoints(ExecutionTerms memory executionTerms, uint256 initialBalance) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`executionTerms`|`ExecutionTerms`|The execution terms|
|`initialBalance`|`uint256`|The initial balance of the token|


### _processExecutorTermsWithAmounts

Process the executor terms with amounts


```solidity
function _processExecutorTermsWithAmounts(ExecutionTerms memory executionTerms) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`executionTerms`|`ExecutionTerms`|The execution terms|


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
function hashAction(Action memory action) public pure returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`Action`|The action to hash|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The EIP712 hash of the action|


### batchGetBalances

Batch get the balances of multiple tokens


```solidity
function batchGetBalances(ExecutionTerms[] memory executionTerms) public view returns (uint256[] memory balances);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`executionTerms`|`ExecutionTerms[]`|The execution terms|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balances`|`uint256[]`|The balances of the tokens|


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

