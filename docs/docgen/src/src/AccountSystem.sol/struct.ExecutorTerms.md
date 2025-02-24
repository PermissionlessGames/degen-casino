# ExecutorTerms
[Git Source](https://github.com/PermissionlessGames/degen-casino/blob/1ac89a7d2fed4901c0cce2dcae17eba9bc74e083/src/AccountSystem.sol)

Terms for executor compensation

Arrays for tokens and their corresponding basis points are zipped together to process executor compensation.
They should be the same length.

Use address(0) in rewardTokens to signify native token of the chain the account is on.

Basis points for a reward token are applied to the difference between DegenCasinoAccount's balances (in that token)
at the end and beginning of a game action. If this difference is positive, that number of basis points are deducted from the
DegenCasinoAccount and transferred to the executor. If this difference is negative, nothing is transferred to the executor.


```solidity
struct ExecutorTerms {
    address[] rewardTokens;
    uint16[] basisPoints;
}
```

