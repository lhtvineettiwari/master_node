#!/bin/sh 
set -e
if [ -z $GIT_BRANCH ] || [ -z $AWS_ACCESS_KEY ] || [ -z$AWS_SECRET ] || [ -z $AWS_REGION ] || [ -z $APP_ID ] || [ -z $KEY_ID ]; then 
  echo "Usage: $GIT_BRANCH" 
  echo "Usage: $AWS_ACCESS_KEY"
  echo "Usage: $AWS_SECRET"
  echo "Usage: $AWS_REGION"
  echo "Usage: $APP_ID"  
  echo "Usage: $KEY_ID"
exit 1
fi
echo Git Branch: "$GIT_BRANCH"
apk add curl
apk add jq
apk add aws-cli
aws configure set aws_access_key_id $AWS_ACCESS_KEY;
aws configure set aws_secret_access_key $AWS_SECRET;
aws configure set region $REGION;
KEYRING="--keyring-backend test"
CHAIN_ID=${CHAIN_ID:-testnet}
MONIKER=${MONIKER:-node0-master}
simd init "$MONIKER" --chain-id "$CHAIN_ID" 
curl https://raw.githubusercontent.com/lhtvineettiwari/genesis/$GIT_BRANCH/genesis.json  >> ~/.simapp/genesis.json
# Accounts Generating and adding in to the genesis
curl https://raw.githubusercontent.com/lhtvineettiwari/genesis/${GIT_BRANCH}/accounts.json > accounts.json
accounts=$(jq -r '.[].name' accounts.json)
echo $accounts_data
echo $accounts
for account_names in $accounts; do
amount=$(jq -r '.[] | select(.name == "'$account_names'") | .amount' accounts.json)
  simd keys add "$account_names" $KEYRING
  simd add-genesis-account $account_names "$amount" $KEYRING
done &> mnemonic_keys.txt
#encrypt/decrypt your text/blob secret with AWS KMS with AWS cli
SECRET_BLOB_PATH="fileb://mnemonic_keys.txt"
REGION=us-east-1
aws kms encrypt --key-id ${KEY_ID} --plaintext ${SECRET_BLOB_PATH} --query CiphertextBlob --region ${REGION} > Encrypteddatafile.base64
## Accounts Operations --------------------------------
echo "Genesis accounts saved successfully to ..."
curl https://raw.githubusercontent.com/lhtvineettiwari/genesis/{$GIT_BRANCH}/stake.json > stake.json
stake_name=$(jq -r '.[].name' stake.json)
stake_amount=$(jq -r '.[].amount' stake.json)
simd gentx $stake_name $stake_amount --chain-id="$CHAIN_ID" $KEYRING 
simd collect-gentxs
simd start
