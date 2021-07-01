#!/bin/bash
rm contracts/*json;
rm contracts/*tvc;
set -e
cd contracts/
tondev sol compile Auction.sol;
tondev sol compile AuctionRoot.sol;
tondev sol compile Bid.sol;
tondev sol compile Bidder.sol;
tondev sol compile DumbReciever.sol;
tondev sol compile Giver.sol;
cd ..
set +e
python3.9 -m pytest -x tests/;
rm contracts/*json;
rm contracts/*tvc;
