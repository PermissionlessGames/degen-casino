# Deploy Gambit contract

This checklist describes how to deploy the Gambit contract

## Enviroment variables
```bash
export RPC='<RPC url example: https://testnet-rpc.game7.io>'
export BLOCKSTOACT=50
export COSTTORESPIN=7
export COSTTOSPIN=10
export KEY='<keyfile path>'
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
  --rpc-url https://testnet-rpc.game7.io \
  --verifier blockscout \
  --verifier-url 'https://testnet.game7.io/api/' \
  0x5C462aBedc9d33C78d07650C5Da041e247DD1348 \
  src/DegenGambit.sol:DegenGambit 
```