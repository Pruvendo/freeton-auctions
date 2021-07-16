/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";

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

    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    uint static public transferDuration;

    address static public lotGiver;
    address static public bidReciever;

    TvmCell static public bidGiverCode;
    address static public root;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    uint public numberOfBids;
    BidData public winner;
    bool public ended;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                               METHODS                                |
    |                                                                      |
    \---------------------------------------------------------------------*/

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root, 102);
        ended = false;
    }

    function revealBid(
        uint256 secret,
        uint128 amount,
        TvmCell data
    ) override external {
        require(addressFitsCode(msg.sender, bidGiverCode, data, msg.pubkey()), 102);

        (
            uint __startTime,
            uint __biddingDuration,
            uint __revealingDuration,
            uint __transferDuration,

            address __root,
            address __auction,
            address __lotReciever,

            uint256 __amountHash
        ) = data.toSlice().decode(
            uint, uint, uint, uint, address, address, address, uint256
        );

        // require(data is correct)

        // require(tvm.checkSign(?????), 201);
    
        if (winner.bidGiver.isNone() || winner.amount < amount) {
            winner = BidData({
                bidGiver: msg.sender,
                lotReciever: __lotReciever, //TODO: data???
                amount: amount
            });
        }
    }

    function end() override public {
        require(!ended, 102);
        require(now >= (startTime + biddingDuration + revealingDuration), 103);
        tvm.accept();
        
        ended = true;

        TvmBuilder builder;
        builder.store(
            a_id,
            startTime,
            biddingDuration,
            revealingDuration,
            transferDuration,
            lotGiver,
            bidReciever,
            bidGiverCode,
            root
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
        uint,
        address,
        address,
        uint128,
        bool
    ) {
        return (
            numberOfBids,
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
        uint numberOfBids_,
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
        numberOfBids_ = numberOfBids;
        ended_ = ended;
    }

    function addressFitsCode(
        address sender,
        TvmCell code,
        TvmCell data,
        uint256 pubkey
    ) private returns (bool) {

        TvmCell stateInit = tvm.buildStateInit(code, data);
        TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, pubkey);
    
        address addr = address(tvm.hash(stateInitWithKey));
        return addr == sender;
    }
}
