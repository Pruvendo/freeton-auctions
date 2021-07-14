/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
// pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Auction.sol";
import "Interfaces.sol";

struct AuctionScenarioData {
    uint256 auctionPubKey;

    address lotGiver;
    address bidReciever;
    address winnerBid;
    address lotReciever;

    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    uint transferDuration;

    bool ended;
}

contract AuctionRoot is IRoot {

    uint public number_of_auctions;

    TvmCell static public auctionCode;
    TvmCell static public lotGiverCode;
    TvmCell static public bidGiverCode;

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
    ) public returns (address auctionAddress) {
        require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > now, 103);
        require(biddingDuration > 0, 103);
        require(revealingDuration > 0, 103);
        require(transferDuration > 0, 103);
        tvm.accept();

        auctionAddress = new Auction {
            code: auctionCode,
            value: 10 ton,
            pubkey: tvm.pubkey(),
            varInit: {
                a_id: number_of_auctions,

                startTime: startTime,
                biddingDuration: biddingDuration,
                revealingDuration: revealingDuration,
                transferDuration: transferDuration,

                lotGiver: lotGiver,
                bidReciever: bidReciever,

                bidGiverCode: bidGiverCode,
                root: this
            }
        }();

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

    function getInfo() public view returns (string) {
        return format("Hello, motherhacker! tvm.pubkey() is {}", tvm.pubkey());
    }

    function addressFitsCode(
        address sender,
        TvmCell code,
        TvmCell data
    ) private returns (bool) {

        TvmCell stateInit = tvm.buildStateInit(code, data);
        TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, tvm.pubkey());
    
        address addr = address(tvm.hash(stateInitWithKey));
        return addr == sender;
    }
}
