# Action
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/a21af4259bb7b6bd065bac891f7074555dc03d5f/src/AccountSystem.sol)

A game action to be executed


```solidity
struct Action {
    address game;
    bytes data;
    uint256 value;
    uint256 request;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`game`|`address`|The target game contract to execute the action on|
|`data`|`bytes`|The encoded function call data to send to the game contract|
|`value`|`uint256`|The amount of native tokens to send with the call|
|`request`|`uint256`|Monotonically increasing request ID to prevent replay attacks|

