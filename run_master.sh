#!/bin/bash 
set -e
KEYRING="--keyring-backend test"
STAKE=${STAKE_TOKEN:-stake}
CHAIN_ID=${CHAIN_ID:-testnet}
MONIKER=${MONIKER:-node0}
simd init "$MONIKER" --chain-id "$CHAIN_ID" 
echo "accounts Generating..." 
for account_names in bob alice harry grandpa; do
  simd keys add "$account_names" $KEYRING
  simd add-genesis-account $account_names "2500000000000000$STAKE" $KEYRING
done &> mnemonic_keys.txt
apk add aws-cli
## aws s3 sync /root/mnemonic_keys.txt s3://dltstack-cosmos-s3/
echo "Genesis accounts saved successfully to ..."
simd gentx bob 100000000000$STAKE --chain-id="$CHAIN_ID" $KEYRING
simd collect-gentxs
simd start