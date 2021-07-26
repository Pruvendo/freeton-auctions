/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractDutchBid.sol";
import "AbstractNativeCurrencyBid.sol";

contract Bid is IBackTransferable, IBid, IGiver, ANCBid, ADutchBid {

    constructor(TvmCell auctionData, TvmCell bidData) public {
        require(tvm.pubkey() != 0, 101);
        setUpAuctionSpecificDataConstructor(auctionData);
        setUpBidSpecificDataConstructor(bidData);
        require(correctConstructorsAuctionData(), 103);
        require(correctConstructorsBidData(), 103);
        tvm.accept();
    }

    function transferRemainsTo(address destination) override external {
        require(tvm.pubkey() == msg.pubkey(), 102);
        require(canTransferRemains(), 102);
        tvm.accept();

        __transferRemains(destination);
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
        require(canRevealBid(), 777);
        require(canRevealAuc(), 777);

        tvm.accept();

        revealToAuction();
    }
}
