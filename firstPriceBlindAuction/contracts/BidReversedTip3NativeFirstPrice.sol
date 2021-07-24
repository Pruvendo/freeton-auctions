/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractFirstPriceBid.sol";
import "AbstractReversedBidTip3Native.sol";

contract Bid is IDoubleGiver, IBackTransferable, IBid, AReversedTip3NativeBid, AFPBid {

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

    function transferTo(address moneyDestination, address resourceDestination) override external {
        require(canTransfer(), 102);
        tvm.accept();

        __transferTo(moneyDestination, resourceDestination);
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
