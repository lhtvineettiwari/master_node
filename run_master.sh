#!/bin/sh 
set -e
if [ "$#" -lt 5 ]; then 
  echo "Usage: $1 GIT_BRANCH" 
  echo "Usage: $2 AWS_ACCESS_KEY"
  echo "Usage: $3 AWS_SECRET"
  echo "Usage: $4 AWS_REGION"
  echo "Usage: $5 APP_ID"   

exit 1
fi
GIT_BRANCH="$1"
AWS_ACCESS_KEY="$2"
AWS_SECRET="$3"
REGION="$4"
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
KEY_ID="8a888a57-7bc4-4a61-b022-5301b8ea916c"
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
