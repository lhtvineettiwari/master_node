KEYRING="--keyring-backend test"
STAKE=${STAKE_TOKEN:-stake}
CHAIN_ID=${CHAIN_ID:-testnet}
MONIKER=${MONIKER:-node0}
echo "accounts Generating..."
names=( bob alice harry grandpa )
for account_names in "${names[@]}"
  do
     simd keys add "$account_names" $KEYRING
     simd add-genesis-account $account_names "2500000000000000$STAKE" $KEYRING
  done &> mnemonic_keys.txt
echo "Genesis accounts saved successfully to ..."

simd gentx bob 100000000000$STAKE --chain-id="$CHAIN_ID" $KEYRING
simd collect-gentxs
simd start