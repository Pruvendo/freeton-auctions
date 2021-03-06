/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "BidNativeCurrencyDutch.sol";


contract Auction is IAuction {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                 DATA                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

    uint static public a_id;

    uint public startTime;
    uint128 startPrice;
    uint128 priceStep;

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

    event NewWinner(address bid, uint128 price);

    constructor(
        uint a_id_,

        uint startTime_,
        uint128 startPrice_,
        uint128 priceStep_,

        address lotGiver_,
        address bidReciever_,

        TvmCell bidGiverCode_,
        address root_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root_, 102);

        a_id = a_id_;
        startTime = startTime_;
        startPrice = startPrice_;
        priceStep = priceStep_;
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
            uint128 startPrice_,
            uint128 priceStep_
        ) = auctionData.toSlice().decode(uint, uint128, uint128);
        require(now >= startTime, 103);
        require((now - startTime) * priceStep < startPrice, 103);
        require(amount_ >= startPrice - (now - startTime) * priceStep, 104);
        require(startTime_ == startTime, 102);
        require(startPrice_ == startPrice, 102);
        require(priceStep_ == priceStep, 103);
        require(root_ == root, 102);
        require(this == auction_);

        require(addressFitsCode(
            msg.sender,
            msg.pubkey()
        ), 102);

        bidGiver = msg.sender;
        lotReciever = lotReciever_;
        winnersPrice = amount_;

        emit NewWinner(msg.sender, amount_);

        __end();
    }

    function __end() private inline {

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

    function end() override external {
        require(now >= startTime, 103);
        require((now - startTime) * priceStep > startPrice, 103);
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

    function getInfo() override external view returns(address bidGiver_, address lotReciever_, uint128 winnersPrice_) {
        bidGiver_ = bidGiver;
        lotReciever_ = lotReciever_;
        winnersPrice_ = winnersPrice;
    }
}
