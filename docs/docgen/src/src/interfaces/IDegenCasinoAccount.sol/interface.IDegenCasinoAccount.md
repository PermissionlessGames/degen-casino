# IDegenCasinoAccount
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/96c4f5bf386b90645fa24f94b3d190fc428bca09/src/interfaces/IDegenCasinoAccount.sol)


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

### player


```solidity
function player() external view returns (address);
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

