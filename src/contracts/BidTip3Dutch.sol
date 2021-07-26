/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractDutchBid.sol";
import "AbstractTip3Bid.sol";

contract Bid is IBid, AT3Bid, ADutchBid {

    constructor(TvmCell auctionData, TvmCell bidData) public {
        require(tvm.pubkey() != 0, 101);
        setUpAuctionSpecificDataConstructor(auctionData);
        setUpBidSpecificDataConstructor(bidData);
        require(correctConstructorsAuctionData(), 103);
        require(correctConstructorsBidData(), 103);
        tvm.accept();
    }

    function transferTo(address destination) override external {
        require(canTransfer(), 102);
        tvm.accept();

        __transferTo(destination);
    }

    function reveal(TvmCell bidData, TvmCell auctionData) override external {
        require(tvm.pubkey() == msg.pubkey(), 102);
        setUpRevealBidData(bidData);
        setUpRevealAuctionData(auctionData);
        require(canRevealBid(), 102);
        require(canRevealAuc(), 102);

        tvm.accept();

        revealToAuction();
    }
}
