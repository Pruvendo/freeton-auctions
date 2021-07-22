/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "BidNativeCurrency.sol";


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

    address bidGiver;
    address lotReciever;
    uint128 winnersPrice;

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
        uint128 amount_,

        uint256 secret_,
        uint256 amountHash_,
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address root_,
        address auction_,
        address lotReciever_
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

        if (bidGiver.isNone() || winnersPrice < amount_) {
            bidGiver = msg.sender;
            lotReciever = lotReciever_;
            winnersPrice = amount_;
        }
    }

    function end() override public {
        require(lotReciever != address(0));
        // TODO tick-tok
        require(now >= (startTime + biddingDuration + revealingDuration), 103);
        tvm.accept();

        TvmBuilder builder;
        builder.store(
            a_id
        );
        TvmCell data = builder.toCell();

        IRoot(root).setWinner({
            bidGiver: bidGiver,
            lotGiver: lotGiver,
            bidReciever: bidReciever,
            lotReciever: lotReciever,
            data: data
        });

        selfdestruct(root);
    }

    function getUpdateableInfo() override public view returns(
        address,
        address,
        uint128,
        bool
    ) {
        return (
            bidGiver,
            lotReciever,
            winnersPrice,
            false
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

        bidGiver_ = bidGiver;
        lotReciever_ = lotReciever;
        amount_ = winnersPrice;

        root_ = root;
        ended_ = false;
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
