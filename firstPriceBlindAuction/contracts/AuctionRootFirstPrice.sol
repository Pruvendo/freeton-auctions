/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "FirstPriceAuction.sol";
import "Interfaces.sol";

contract AuctionRootFirstPrice is IRoot {

    uint public numberOfAuctions;
    uint public numberOfActiveAuctions;

    TvmCell public auctionCode;
    TvmCell public lotGiverCode;
    TvmCell public bidGiverCode;

    uint128 DEPLOY_AUCTION_COST;
    uint128 END_AUCTION_COST;

    event AuctionStarted(address auction);
    event AuctionEnded(address auction, address winner);

    constructor(
        TvmCell auctionCode_,
        TvmCell lotGiverCode_,
        TvmCell bidGiverCode_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();

        auctionCode = auctionCode_;
        lotGiverCode = lotGiverCode_;
        bidGiverCode = bidGiverCode_;

        DEPLOY_AUCTION_COST = 3 ton;
        END_AUCTION_COST = 1 ton;
    }

    function startAuctionScenario(
        address lotGiver,
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint transferDuration
    ) external returns (address auctionAddress) {
        require(msg.pubkey() == tvm.pubkey(), 102);
        require(address(this).balance > END_AUCTION_COST * (numberOfActiveAuctions + 1) + DEPLOY_AUCTION_COST, 104);
        require(startTime > now, 104);
        require(biddingDuration > 0, 103);
        require(revealingDuration > 0, 103);
        require(transferDuration > 0, 103);
        tvm.accept();

        auctionAddress = new Auction {
            code: auctionCode,
            value: 2 ton,
            pubkey: tvm.pubkey()
        }({
                a_id_: numberOfAuctions,

                startTime_: startTime,
                biddingDuration_: biddingDuration,
                revealingDuration_: revealingDuration,
                transferDuration_: transferDuration,

                lotGiver_: lotGiver,
                bidReciever_: bidReciever,

                bidGiverCode_: bidGiverCode,
                root_: address(this)
            });

        numberOfAuctions += 1;
        numberOfActiveAuctions += 1;

        emit AuctionStarted(auctionAddress);
        return auctionAddress;
    }

    function setWinner(
        address bidGiver,
        address lotGiver,
        address bidReciever,
        address lotReciever,
        TvmCell data
    ) override external {
        require(addressFitsCode(msg.sender, auctionCode, data));
        tvm.accept();

        // transfer money <-> prize
        IGiver(bidGiver).transferTo(bidReciever);
        IGiver(lotGiver).transferTo(lotReciever);
        numberOfActiveAuctions -= 1;

        emit AuctionEnded(msg.sender, bidGiver);
    }

    function addressFitsCode(
        address sender,
        TvmCell code,
        TvmCell data
    ) private inline view returns (bool) {

        TvmCell stateInit = tvm.buildStateInit(code, data);
        TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, tvm.pubkey());

        address addr = address(tvm.hash(stateInitWithKey));
        return addr == sender;
    }
}
