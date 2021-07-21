/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "GiverNativeCurrency.sol";

contract Bid is IGiver, IBackTransferable, IBid {
    uint public startTime;
    uint public biddingDuration;
    uint public revealingDuration;
    uint public transferDuration;
    
    address public root;
    address public auction;
    address public lotReciever;

    uint256 public amountHash;
    uint256 public secret;
    uint128 public amount;

    // TODO delete me
    TvmCell public bidGiverCode;

    constructor(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,
        
        address root_,
        address auction_,
        address lotReciever_,

        uint256 amountHash_,

        TvmCell bidGiverCode_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(now < startTime_ + biddingDuration_, 103);
        startTime = startTime_;
        biddingDuration = biddingDuration_;
        revealingDuration = revealingDuration_;
        transferDuration = transferDuration_;
        root = root_;
        auction = auction_;
        lotReciever = lotReciever_;
        amountHash = amountHash_;

        bidGiverCode = bidGiverCode_;

        require(addressFitsCode(this, tvm.pubkey(), bidGiverCode), 777);
        tvm.accept();
    }

    function addressFitsCode(
        address sender,
        uint256 pubkey,
        TvmCell code
    ) private inline view returns (bool) {

        TvmCell stateInit = tvm.buildStateInit({
            code: code,
            contr: Bid,
            varInit: {},
            pubkey: pubkey
        });
    
        address addr = address(tvm.hash(stateInit));
        return addr == sender;
    }

    function transferRemainsTo(address destination) override external {
        require(tvm.pubkey() == msg.pubkey(), 102);
        require(
            now >= (startTime + biddingDuration + revealingDuration + transferDuration),
            103
        );
        tvm.accept();

        destination.transfer({
            value: 0 ton,
            bounce: false,
            flag: 128
        });
    }

    function transferTo(address destination) override external {
        require(msg.sender == root, 102);
        tvm.accept();

        destination.transfer(amount, false);
    }

    function reveal(
        TvmCell data
    ) override external {
        require(msg.value == 0, 104);
        require(secret == 0, 103);
        require(tvm.pubkey() == msg.pubkey(), 102);

        (uint128 amount_, uint256 secret_) = data.toSlice().decode(uint128, uint256);

        TvmBuilder builder;
        builder.store(
            secret_,
            "Let me take you down, cos I'm going to Strawberry Fields Nothing is real and nothing to get hung about Strawberry Fields forever",
            amount_
        );
        uint256 hash_ = tvm.hash(builder.toCell());
        require(amountHash == hash_, 201);

        require(address(this).balance >= amount + 2);

        tvm.accept();

        amount = amount_;
        secret = secret_;

        IAuction(auction).revealBid{value: 1 ton}({
            amount_: amount,

            secret_: secret,
            startTime_: startTime,
            biddingDuration_: biddingDuration,
            revealingDuration_: revealingDuration,
            transferDuration_: transferDuration,
            amountHash_: amountHash,

            root_: root,
            auction_: auction,
            lotReciever_: lotReciever
        });
    }

    receive() external {
        require(false, 104);
    }
}
