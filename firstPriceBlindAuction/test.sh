#!/bin/bash
rm contracts/*json;
rm contracts/*tvc;
set -e
cd contracts/
tondev sol compile Auction.sol;
tondev sol compile AuctionRoot.sol;
tondev sol compile Bid.sol;
tondev sol compile Bidder.sol;
tondev sol compile Giver.sol;
cd ..
set +e
pytest -o log_cli=true tests/;
rm contracts/*json;
rm contracts/*tvc;
