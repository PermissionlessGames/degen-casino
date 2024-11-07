# Deploy Gambit contract

This checklist describes how to deploy the Gambit contract

## Enviroment variables
```bash
export RPC='<RPC url example: https://testnet-rpc.game7.io>'
export BLOCKSTOACT=20
export COSTTORESPIN=7
export COSTTOSPIN=10
export KEY='<keyfile path>'
export VERIFIERURL='<verifier url example: https://testnet.game7.io/api/>'
```

## Deploy
```bash
bin/casino gambit deploy \
    --blocks-to-act $BLOCKSTOACT \
    --cost-to-respin $COSTTORESPIN \
    --cost-to-spin $COSTTOSPIN \
    --keyfile $KEY \
    --rpc $RPC
```

## Verify Contract

```bash
forge verify-contract \
  --rpc-url $RPC \
  --verifier blockscout \
  --verifier-url $VERIFIERURL \
  '<deployment address>' \
  src/DegenGambit.sol:DegenGambit 
```