/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "BidNativeCurrencyEnglish.sol";


contract Auction is IAuction {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    uint static public a_id;

    uint public startTime;
    uint public biddingDuration;
    uint public transferDuration;
    uint128 public minimalStep;

    address public lotGiver;
    address public bidReciever;

    TvmCell public bidGiverCode;
    address public root;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                               STATE                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    address public bidGiver;
    address public lotReciever;
    uint128 public winnersPrice;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                               METHODS                                |
    |                                                                      |
    \---------------------------------------------------------------------*/

    // TODO а что на счёт событий???

    constructor(
        uint a_id_,

        uint startTime_,
        uint biddingDuration_,
        uint transferDuration_,
        uint128 minimalStep_,

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
        transferDuration = transferDuration_;
        minimalStep = minimalStep_;
        lotGiver = lotGiver_;
        bidReciever = bidReciever_;
        bidGiverCode = bidGiverCode_;
        root = root_;
    }

    function revealBid(
        uint128 amount_,

        TvmCell auctionData,

        address root_,
        address auction_,
        address lotReciever_
    ) override external {

        (
            uint startTime_,
            uint biddingDuration_,
            uint transferDuration_
        ) = auctionData.toSlice().decode(uint, uint, uint);

        require(startTime_ == startTime, 777);
        require(biddingDuration_ == biddingDuration, 777);
        require(transferDuration_ == transferDuration, 777);
        require(root_ == root, 777);
        require(auction_ == address(this), 777);

        require(addressFitsCode(
            msg.sender,
            msg.pubkey()
        ), 777);

        if (bidGiver.isNone() || (winnersPrice + minimalStep) <= amount_) {
            bidGiver = msg.sender;
            lotReciever = lotReciever_;
            winnersPrice = amount_;
        }
    }

    function end() override public {
        require(lotReciever != address(0));
        // TODO tick-tok
        require(now >= (startTime + biddingDuration), 103);
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
