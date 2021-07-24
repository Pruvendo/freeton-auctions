/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasAmount.sol";

abstract contract AEnglishBid is AHasAmount {

    uint public startTime;
    uint public biddingDuration;
    uint public transferDuration;

    address public root;
    address public auction;
    address public lotReciever;

    function setUpAuctionSpecificDataConstructor(TvmCell auctionData) internal inline {

        (startTime, biddingDuration, transferDuration) = auctionData
            .toSlice().decode(uint, uint, uint);
    }

    function correctConstructorsAuctionData()
    internal inline returns (bool) {
        return true;
    }

    function canTransfer() internal inline returns (bool) {
        return msg.sender == root;
    }

    function canTransferRemains() internal inline returns (bool) {
        return now >= (startTime + biddingDuration + transferDuration);
    }

    function canRevealAuc() internal inline returns (bool) {
        return (now >= startTime)
            && (now < startTime + biddingDuration);
    }

    function setUpRevealAuctionData(TvmCell data) internal inline {}

    function revealToAuction() internal inline {
        TvmBuilder builder;
        builder.store(startTime, biddingDuration, transferDuration);
        IAuction(auction).revealBid{value: 1 ton}({
            amount_: amount,

            auctionData: builder.toCell(),

            root_: root,
            auction_: auction,
            lotReciever_: lotReciever
        });
    }
}
