# Deploy Testable Gambit contract

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
bin/technician testable-gambit deploy \
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
  0x32Ab35AF615241D80801C1cFbF5798762BA31f3b \
  src/testable/TestableDegenGambit.sol:TestableDegenGambit 
```