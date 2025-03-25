# Deploy Gambit contract

This checklist describes how to deploy the Gambit contract

## Enviroment variables
```bash
export RPC='<rpc example for g7 testnet https://testnet-rpc.game7.io>'
export BLOCKSTOACT=50
export COSTTORESPIN=7
export COSTTOSPIN=10
export KEY='<Path to keyfile>'
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
  0xe2B629be92086D9231f008018AA87E5047A453C5 \
  src/DegenGambit.sol:DegenGambit 
```