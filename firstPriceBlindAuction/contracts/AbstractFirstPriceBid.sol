/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasAmount.sol";

abstract contract AFPBid is AHasAmount {

    // auction specific
    uint public startTime;
    uint public biddingDuration;
    uint public revealingDuration;
    uint public transferDuration;

    address public root;
    address public auction;
    address public lotReciever;

    uint256 public amountHash;
    uint256 public secret;

    function setUpAuctionSpecificDataConstructor(TvmCell auctionData) internal inline {

        (TvmCell cell1, TvmCell cell2, TvmCell cell3)= auctionData.toSlice().decode(TvmCell, TvmCell, TvmCell);

        (
            startTime,
            biddingDuration,
            revealingDuration
        ) = cell1.toSlice().decode(uint, uint, uint);

        (
            transferDuration,
            root,
            auction
        ) = cell2.toSlice().decode(uint, address, address);

        (
            lotReciever,
            amountHash
        ) = cell3.toSlice().decode(address, uint256);
    }

    function correctConstructorsAuctionData()
    internal inline returns (bool) {
        return now < startTime + biddingDuration;
    }

    function canTransfer() internal inline returns (bool) {
        return msg.sender == root;
    }

    function canTransferRemains() internal inline returns (bool) {
        return now >= (startTime + biddingDuration + revealingDuration + transferDuration);
    }

    function canRevealAuc() internal inline returns (bool) {
        return (secret == 0)
            || (now >= startTime + biddingDuration)
            || (now < startTime + biddingDuration + revealingDuration);
    }

    function setUpRevealAuctionData(TvmCell data) internal inline {
        (amount, secret) = data.toSlice().decode(uint128, uint256);
    }

    function revealToAuction() internal inline {
        TvmBuilder builder1;
        TvmBuilder builder2;
        TvmBuilder builder3;
        builder1.store(secret, amountHash, startTime);
        builder2.store(biddingDuration, revealingDuration, transferDuration);
        builder3.store(builder1.toCell(), builder2.toCell());
        IAuction(auction).revealBid{value: 1 ton}({
            amount_: amount,

            auctionData: builder3.toCell(),
            // secret_: secret,
            // amountHash_: amountHash,
            // startTime_: startTime,
            // biddingDuration_: biddingDuration,
            // revealingDuration_: revealingDuration,
            // transferDuration_: transferDuration,

            root_: root,
            auction_: auction,
            lotReciever_: lotReciever
        });
    }
}
