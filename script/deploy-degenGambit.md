# Deploy Gambit contract

This checklist describes how to deploy the Gambit contract

## Enviroment variables
```bash
export RPC='<rpc json link>'
export BLOCKSTOACT=20
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
  0x4074188FDf26b26980456e6553A61b92D7A05A4E \
  src/DegenGambit.sol:DegenGambit 
```