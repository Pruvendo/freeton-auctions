#!/bin/bash
set -e

NETWORK="http://127.0.0.1"
GIVER_ADDRESS=0:d5f5cfc4b52d2eb1bd9d3a8e51707872c7ce0c174facddd0e06ae5ffd17d2fcd

trap "
    rm contracts/*.json;
    rm contracts/*.tvc;
    rm debots/*.json;
    rm debots/*.tvc;
    rm debots/*.log;
    rm *.log;
    rm *.json;
" EXIT

echo "__________________________________________
1. Generate keys"
# tondev se reset ПАЧИМУ???????
temp=$(tonos-cli genphrase | tail -1)
PHRASE=${temp:14:-1}
tonos-cli getkeypair keyfile.json "$PHRASE"


echo "__________________________________________
2. Compile contracts"
cd ./contracts
tondev sol compile Auction.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc Auction.tvc)
auc_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile AuctionRoot.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc AuctionRoot.tvc)
auc_root_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile Bid.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc Bid.tvc)
bid_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile Giver.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc Giver.tvc)
giver_code=$(echo $temp | grep -oP 'code: \K\S+')


echo "__________________________________________
3. Generate auc_root_address"
cd ../debots
tonos-cli getkeypair ../keyfile.json "$PHRASE"

tonos-cli genaddr ../contracts/AuctionRoot.tvc ../contracts/AuctionRoot.abi.json --genkey ../keyfile.json > AuctionRoot.log
auc_root_address=$(cat AuctionRoot.log | grep "Raw address:" | cut -d ' ' -f 3)
echo "auc_root_address: $auc_root_address"


echo "__________________________________________
4. Give to Root"
cd ..
echo $auc_root_address
tonos-cli --url http://127.0.0.1/ call $GIVER_ADDRESS \
    submitTransaction "{\"dest\":\"$auc_root_address\",\"value\":10000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" \
    --abi static/SafeMultisigWallet.abi.json \
    --sign static/SafeMultisigWallet.keys.json


echo "__________________________________________
5. Deploy Root"
tonos-cli --url $NETWORK \
    deploy contracts/AuctionRoot.tvc \
    --sign keyfile.json \
    --abi contracts/AuctionRoot.abi.json \
    "{
        \"auctionCode_\": \"$auc_code\",
        \"giverCode_\": \"$giver_code\",
        \"bidCode_\": \"$bid_code\",
        \"rootId_\": 0
    }";


echo "__________________________________________
6. Deploy Debot"
pwd
ls -la
cd ./debots
tondev sol compile DRoot.sol
cd ..
temp=$(bash deploy_debot.sh debots/DRoot.tvc | tail -1)
ADDRESS=${temp:6}
echo "Debot deployed at address: $ADDRESS"
tonos-cli --url http://127.0.0.1 debot fetch $ADDRESS
