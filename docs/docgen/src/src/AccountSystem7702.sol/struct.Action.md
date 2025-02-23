# Action
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/a6696f00c13f9274ae713de85e5b1212b5977800/src/AccountSystem7702.sol)

A game action to be executed


```solidity
struct Action {
    address target;
    bytes data;
    uint256 value;
    uint256 nonce;
    uint256 expiration;
    address feeToken;
    uint256 feeValue;
    bool isBasisPoints;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target contract to execute the action on|
|`data`|`bytes`|The encoded function call data to send to the game contract|
|`value`|`uint256`|The amount of native tokens to send with the call|
|`nonce`|`uint256`|nonce to prevent replay attacks|
|`expiration`|`uint256`||
|`feeToken`|`address`||
|`feeValue`|`uint256`||
|`isBasisPoints`|`bool`||

