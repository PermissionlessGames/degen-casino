

## Enviroment variables
```bash
export RPC='<RPC url example: https://testnet-rpc.game7.io>'
export BLOCKSTOACT=50
export COSTTORESPIN=7
export COSTTOSPIN=10
export KEY='<keyfile path>'
```

```bash 
bin/casino dual-fi deploy \
    --rpc $RPC \
    --keyfile $KEY \
    ---name-0 $NAME \
    --basis $BASIS \
    --initial-amount-0-token $INITIALTOKEN \
    --initial-amount-native $INITIALNATIVE \
    --symbol $SYMBOL \
    --token-a $TOKEN \
    --trim-value $TRIMVAULE \
    --verify 


```