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
tondev sol compile FirstPriceAuction.sol;
tondev sol compile AuctionRootFirstPrice.sol;
tondev sol compile BidNativeCurrencyFirstPrice.sol;

tondev sol compile DutchAuction.sol;
tondev sol compile AuctionRootDutch.sol;
tondev sol compile BidNativeCurrencyDutch.sol;

tondev sol compile EnglishAuction.sol;
tondev sol compile AuctionRootEnglish.sol;
tondev sol compile BidNativeCurrencyEnglish.sol;

tondev sol compile GiverNativeCurrency.sol;

tondev sol compile __DumbReciever.sol;
tondev sol compile __HashCalc.sol;
tondev sol compile __NativeCurrencyFirstPriceBidRevealArgCalc.sol;
tondev sol compile __NativeCurrencyFirstPriceBidConstructorArgCalc.sol;
tondev sol compile __NativeCurrencyDutchBidRevealArgCalc.sol;
tondev sol compile __NativeCurrencyDutchBidConstructorArgCalc.sol;
tondev sol compile __NativeCurrencyEnglishBidRevealArgCalc.sol;
tondev sol compile __NativeCurrencyEnglishBidConstructorArgCalc.sol;
cd ..
set +e
python3.9 -m pytest -v -x tests/;
