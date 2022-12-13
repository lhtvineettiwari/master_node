#!/bin/bash 
set -e
KEYRING="--keyring-backend test"
STAKE=${STAKE_TOKEN:-stake}
CHAIN_ID=${CHAIN_ID:-testnet}
MONIKER=${MONIKER:-node0}
simd init "$MONIKER" --chain-id "$CHAIN_ID" 
echo "accounts Generating..." 
simd keys add bob $KEYRING  &> mnemonic_keys.txt
simd add-genesis-account bob "2500000000000000$STAKE" $KEYRING
echo "Genesis accounts saved successfully to ..."
simd gentx bob 100000000000$STAKE --chain-id="$CHAIN_ID" $KEYRING
simd collect-gentxs
simd start