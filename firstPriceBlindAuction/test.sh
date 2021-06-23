rm contracts/*json;
rm contracts/*tvc;
cd contracts/
tondev sol compile AuctionRoot.sol;
tondev sol compile Auction.sol;
tondev sol compile Giver.sol;
tondev sol compile Bid.sol;
cd ..
pytest -o log_cli=true tests/;
rm contracts/*json;
rm contracts/*tvc;