#!/bin/bash
trap "
    rm contracts/*.json;
    rm contracts/*.tvc;
    rm debots/*.json;
    rm debots/*.tvc;
    rm debots/*.log;
    rm *.log;
    rm *.json;
" EXIT

set -e
cd contracts/
tondev sol compile Auction.sol;
tondev sol compile AuctionRoot.sol;
tondev sol compile BidNativeCurrency.sol;
tondev sol compile GiverNativeCurrency.sol;
tondev sol compile BidNativeCurrency.sol;
tondev sol compile __DumbReciever.sol;
tondev sol compile __HashCalc.sol;
tondev sol compile __NativeCurrencyBidRevealArgCalc.sol;
tondev sol compile __NativeCurrencyBidConstructorArgCalc.sol;
cd ..
set +e
python3.9 -m pytest -v -x tests/;
