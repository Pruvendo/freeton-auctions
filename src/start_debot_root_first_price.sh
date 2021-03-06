#!/bin/bash
set -e

NETWORK="http://127.0.0.1"
GIVER_ADDRESS=0:d5f5cfc4b52d2eb1bd9d3a8e51707872c7ce0c174facddd0e06ae5ffd17d2fcd

function nice_echo() {
    local w=$(tput cols);
    python -c "s=\"#\"*(($w - len(\"$1\"))//2 - 1);print(\"\n\" + s + (\" $1 \" if \"$1\" else \"###\") + s)";
};

START_PATH=$(pwd);

trap "
    set +e;
    cd $START_PATH;
    rm contracts/*.json;
    rm contracts/*.tvc;
    rm debots/*.json;
    rm debots/*.tvc;
    rm debots/*.log;
    rm *.log;
    rm *.json;
    set -e
" ERR EXIT SIGINT SIGTERM KILL

nice_echo "1. Generate keys"
# tondev se reset ПАЧИМУ???????
temp=$(tonos-cli genphrase | tail -1)
PHRASE=${temp:14:-1}
tonos-cli getkeypair keyfile.json "$PHRASE"


nice_echo "2. Compile contracts"
cd ./contracts
tondev sol compile FirstPriceAuction.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc FirstPriceAuction.tvc)
auc_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile AuctionRootFirstPrice.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc AuctionRootFirstPrice.tvc)
auc_root_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile BidNativeCurrencyFirstPrice.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc BidNativeCurrencyFirstPrice.tvc)
bid_code=$(echo $temp | grep -oP 'code: \K\S+')

tondev sol compile GiverNativeCurrency.sol > /dev/null
temp=$(../static/tvm_linker decode --tvc GiverNativeCurrency.tvc)
giver_code=$(echo $temp | grep -oP 'code: \K\S+')


nice_echo "3. Generate auc_root_address"
cd ../debots
# tonos-cli getkeypair ../keyfile.json "$PHRASE"

tonos-cli genaddr ../contracts/AuctionRootFirstPrice.tvc ../contracts/AuctionRootFirstPrice.abi.json \
    --setkey ../keyfile.json > AuctionRootFirstPrice.log
    # --data "{
    #     \"auctionCode\": \"$auc_code\",
    #     \"giverCode\": \"$giver_code\",
    #     \"bidCode\": \"$bid_code\",
    #     \"rootId\": 0
    # }"  \
    # --genkey ../keyfile.json > AuctionRootFirstPrice.log
auc_root_address=$(cat AuctionRootFirstPrice.log | grep "Raw address:" | cut -d ' ' -f 3)
echo "auc_root_address: $auc_root_address"


nice_echo "4. Give to Root"
cd ..
echo $auc_root_address
tonos-cli --url http://127.0.0.1/ call $GIVER_ADDRESS \
    submitTransaction \
    "{
        \"dest\":\"$auc_root_address\",
        \"value\":$(python -c "print(2000 * 10**9)"),
        \"bounce\":false,\"allBalance\":false,
        \"payload\":\"\"
    }" \
    --abi static/SafeMultisigWallet.abi.json \
    --sign static/SafeMultisigWallet.keys.json


nice_echo "5. Deploy Root"
tonos-cli --url $NETWORK \
    deploy contracts/AuctionRootFirstPrice.tvc \
    --sign keyfile.json \
    --abi contracts/AuctionRootFirstPrice.abi.json \
    "{
        \"auctionCode_\": \"$auc_code\",
        \"lotGiverCode_\": \"$giver_code\",
        \"bidGiverCode_\": \"$bid_code\"
    }";


nice_echo "6. Deploy Debot"
pwd
ls -la
cd ./debots
tondev sol compile DRootFirstPrice.sol
cd ..
temp=$(bash deploy_debot.sh debots/DRootFirstPrice.tvc | tail -1)
ADDRESS=${temp:6}
nice_echo "AUTH INFO"
echo "auc_root_address: $auc_root_address"
echo "Debot deployed at address: $ADDRESS"
temp=$(tonos-cli genpubkey "$PHRASE" | grep -oP 'Public key: \K\S+')
echo "pubkey: $temp"
echo "phrase: $PHRASE"
nice_echo
tonos-cli --url http://127.0.0.1 debot fetch $ADDRESS
