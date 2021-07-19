#!/bin/bash
rm contracts/*json;
rm contracts/*tvc;
set -e
cd contracts/
tondev sol compile Auction.sol;
tondev sol compile AuctionRoot.sol;
tondev sol compile BidNativeCurrency.sol;
tondev sol compile DumbReciever.sol;
tondev sol compile GiverNativeCurrency.sol;
tondev sol compile BidNativeCurrency.sol;
tondev sol compile HashCalc.sol;
cd ..
set +e
python3.9 -m pytest -v -x tests/;
rm contracts/*json;
rm contracts/*tvc;
