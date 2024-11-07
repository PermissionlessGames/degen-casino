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