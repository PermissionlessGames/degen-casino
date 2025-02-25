# Action
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/9c6d5d70b9c8f85602727ed0d0bb7e05794c273b/src/AccountSystem7702Alt.sol)

A game action to be executed


```solidity
struct Action {
    address target;
    bytes data;
    uint256 value;
    uint256 nonceOrExpiration;
    ExecutionTerms[] executionTerms;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target contract to execute the action on|
|`data`|`bytes`|The encoded function call data to send to the game contract|
|`value`|`uint256`|The amount of native tokens to send with the call|
|`nonceOrExpiration`|`uint256`||
|`executionTerms`|`ExecutionTerms[]`||

