/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasBalance.sol";

abstract contract ADutchBid is AHasBalance {

    uint public startTime;
    uint128 public startPrice;
    uint128 public priceStep;

    address public root;
    address public auction;
    address public lotReciever;

    function setUpAuctionSpecificDataConstructor(TvmCell auctionData) internal inline {
        (TvmCell cell1, TvmCell cell2)= auctionData.toSlice().decode(TvmCell, TvmCell);

        (startTime, startPrice, priceStep) = cell1.toSlice().decode(uint, uint128, uint128);
        (root, auction, lotReciever) = cell2.toSlice().decode(address, address, address);
    }

    function correctConstructorsAuctionData() internal inline returns (bool) {
        return true;
    }

    function canTransfer() internal inline returns (bool) {
        return true;
    }

    function canTransferRemains() internal inline returns (bool) {
        return (now >= startTime) && ((now - startTime) * priceStep > startPrice);
    }

    function canRevealAuc() internal inline returns (bool) {
        return true;
    }

    function setUpRevealAuctionData(TvmCell data) internal inline {
        (amount) = data.toSlice().decode(uint128);
    }

    function revealToAuction() internal inline {
        TvmBuilder builder1;
        builder1.store(startTime, startPrice, priceStep);
        IAuction(auction).revealBid{value: 1 ton}({
            amount_: amount,

            auctionData: builder1.toCell(),

            root_: root,
            auction_: auction,
            lotReciever_: lotReciever
        });
    }
}
