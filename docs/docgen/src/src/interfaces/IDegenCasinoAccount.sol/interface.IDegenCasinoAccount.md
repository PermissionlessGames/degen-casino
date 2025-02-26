# IDegenCasinoAccount
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/41aaa20bb5d115d7f7f5144fd0b0f95fc755f416/src/interfaces/IDegenCasinoAccount.sol)


## Functions
### accountVersion


```solidity
function accountVersion() external view returns (string memory);
```

### actionHash


```solidity
function actionHash(Action0 memory action) external view returns (bytes32);
```

### drain


```solidity
function drain(address[] memory tokenAddresses) external;
```

### eip712Domain


```solidity
function eip712Domain()
    external
    view
    returns (
        bytes1 fields,
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract,
        bytes32 salt,
        uint256[] memory extensions
    );
```

### executorTermsHash


```solidity
function executorTermsHash(ExecutorTerms1 memory terms) external view returns (bytes32);
```

### lastRequest


```solidity
function lastRequest() external view returns (uint256);
```

### play


```solidity
function play(
    Action2 memory action,
    ExecutorTerms3 memory terms,
    bytes memory playerActionSignature,
    bytes memory playerTermsSignature
) external;
```

### playInSession


```solidity
function playInSession(
    Action4 memory action,
    ExecutorTerms5 memory terms,
    uint256 sessionID,
    uint256 expiration,
    bytes memory playerSessionSignature,
    bytes memory playerTermsSignature
) external;
```

### player


```solidity
function player() external view returns (address);
```

### sessionHash


```solidity
function sessionHash(address executor, uint256 sessionID, uint256 expiration) external view returns (bytes32);
```

### withdraw


```solidity
function withdraw(address[] memory tokenAddresses, uint256[] memory amounts) external;
```

## Events
### EIP712DomainChanged

```solidity
event EIP712DomainChanged();
```

## Errors
### ActionFailed

```solidity
error ActionFailed();
```

### FailedToSendReward

```solidity
error FailedToSendReward();
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

### InvalidShortString

```solidity
error InvalidShortString();
```

### MismatchedArrayLengths

```solidity
error MismatchedArrayLengths();
```

### RequestTooLow

```solidity
error RequestTooLow();
```

### SessionExpired

```solidity
error SessionExpired();
```

### StringTooLong

```solidity
error StringTooLong(string str);
```

### Unauthorized

```solidity
error Unauthorized();
```

### Unsuccessful

```solidity
error Unsuccessful();
```

## Structs
### Action0

```solidity
struct Action0 {
    address game;
    bytes data;
    uint256 value;
    uint256 request;
}
```

### ExecutorTerms1

```solidity
struct ExecutorTerms1 {
    address[] rewardTokens;
    uint16[] basisPoints;
}
```

### Action2

```solidity
struct Action2 {
    address game;
    bytes data;
    uint256 value;
    uint256 request;
}
```

### ExecutorTerms3

```solidity
struct ExecutorTerms3 {
    address[] rewardTokens;
    uint16[] basisPoints;
}
```

### Action4

```solidity
struct Action4 {
    address game;
    bytes data;
    uint256 value;
    uint256 request;
}
```

### ExecutorTerms5

```solidity
struct ExecutorTerms5 {
    address[] rewardTokens;
    uint16[] basisPoints;
}
```

