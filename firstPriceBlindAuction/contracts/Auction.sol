/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "BidNativeCurrency.sol";

struct BidData {
    address bidGiver;
    address lotReciever;
    uint128 amount;
}

contract Auction is IAuction {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                STATE                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

    uint static public a_id;

    uint public startTime;
    uint public biddingDuration;
    uint public revealingDuration;
    uint public transferDuration;

    address public lotGiver;
    address public bidReciever;

    TvmCell public bidGiverCode;
    address public root;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    BidData public winner;
    bool public ended;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                               METHODS                                |
    |                                                                      |
    \---------------------------------------------------------------------*/

    constructor(
        uint a_id_,

        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address lotGiver_,
        address bidReciever_,

        TvmCell bidGiverCode_,
        address root_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root_, 102);
        
        ended = false;
        a_id = a_id_;
        startTime = startTime_;
        biddingDuration = biddingDuration_;
        revealingDuration = revealingDuration_;
        transferDuration = transferDuration_;
        lotGiver = lotGiver_;
        bidReciever = bidReciever_;
        bidGiverCode = bidGiverCode_;
        root = root_;
    }

    function revealBid(
        uint256 secret_,
        uint128 amount_,
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,
        address root_,
        address auction_,
        address lotReciever_,
        uint256 amountHash_
    ) override external {

        require(startTime_ == startTime, 777);
        require(biddingDuration_ == biddingDuration, 777);
        require(revealingDuration_ == revealingDuration, 777);
        require(transferDuration_ == transferDuration, 777);
        require(root_ == root, 777);
        require(auction_ == address(this), 777);

        require(addressFitsCode(
            msg.sender,
            msg.pubkey()
        ), 777);
    
        if (winner.bidGiver.isNone() || winner.amount < amount_) {
            winner = BidData({
                bidGiver: msg.sender,
                lotReciever: lotReciever_, //TODO: data???
                amount: amount_
            });
        }
    }

    function end() override public {
        require(!ended, 102);
        require(winner.lotReciever != address(0));
        require(now >= (startTime + biddingDuration + revealingDuration), 103);
        tvm.accept();
        
        ended = true;

        TvmBuilder builder;
        builder.store(
            a_id
        );
        TvmCell data = builder.toCell();
        
        IRoot(root).setWinner({
            bidGiver: winner.bidGiver,
            lotGiver: lotGiver,
            bidReciever: bidReciever,
            lotReciever: winner.lotReciever,
            data: data
        });
    }

    function getUpdateableInfo() override public view returns(
        address,
        address,
        uint128,
        bool
    ) {
        return (
            winner.bidGiver,
            winner.lotReciever,
            winner.amount,
            ended
        );
    }

    function getAllInfo() override public view returns(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address lotGiver_,
        address bidReciever_,

        address bidGiver_,
        address lotReciever_,
        uint128 amount_,

        address root_,
        bool ended_
    ) {
        startTime_ = startTime;
        biddingDuration_ = biddingDuration;
        revealingDuration_ = revealingDuration;
        transferDuration_ = transferDuration;

        lotGiver_ = lotGiver;
        bidReciever_ = bidReciever;

        bidGiver_ = winner.bidGiver;
        lotReciever_ = winner.lotReciever;
        amount_ = winner.amount;

        root_ = root;
        ended_ = ended;
    }

    function addressFitsCode(
        address sender,
        uint256 pubkey
    ) private inline view returns (bool) {

        return true;
        TvmCell stateInit = tvm.buildStateInit({
            code: bidGiverCode,
            contr: Bid,
            varInit: {},
            pubkey: pubkey
        });
    
        address addr = address(tvm.hash(stateInit));
        return addr == sender;
    }
}
