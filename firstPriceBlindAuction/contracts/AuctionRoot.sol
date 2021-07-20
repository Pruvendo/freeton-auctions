/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Auction.sol";
import "Interfaces.sol";

contract AuctionRoot is IRoot {

    uint public number_of_auctions;

    TvmCell public auctionCode;
    TvmCell public lotGiverCode;
    TvmCell public bidGiverCode;

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
    }

    function startAuctionScenario(
        address lotGiver,
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint transferDuration
    ) override external returns (address auctionAddress) {
        require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > now, 103);
        require(biddingDuration > 0, 103);
        require(revealingDuration > 0, 103);
        require(transferDuration > 0, 103);
        tvm.accept();

        auctionAddress = new Auction {
            code: auctionCode,
            value: 10 ton,
            pubkey: tvm.pubkey()
        }({
                a_id_: number_of_auctions,

                startTime_: startTime,
                biddingDuration_: biddingDuration,
                revealingDuration_: revealingDuration,
                transferDuration_: transferDuration,

                lotGiver_: lotGiver,
                bidReciever_: bidReciever,

                bidGiverCode_: bidGiverCode,
                root_: address(this)
            });

        number_of_auctions += 1;
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
