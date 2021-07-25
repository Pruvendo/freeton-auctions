/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasBalance.sol";

abstract contract AEnglishBid is AHasBalance {

    uint public startTime;
    uint public biddingDuration;
    uint public transferDuration;

    address public root;
    address public auction;
    address public lotReciever;

    function setUpAuctionSpecificDataConstructor(TvmCell auctionData) internal inline {

        (TvmCell cell1, TvmCell cell2)= auctionData.toSlice().decode(TvmCell, TvmCell);

        (startTime, biddingDuration, transferDuration) = cell1.toSlice().decode(uint, uint, uint);
        (root, auction, lotReciever) = cell2.toSlice().decode(address, address, address);
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

    function setUpRevealAuctionData(TvmCell data) internal inline {
        (amount) = data.toSlice().decode(uint128);
    }

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
