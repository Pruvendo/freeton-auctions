/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid is IBid {

    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    uint static public transferDuration;

    address static public root;
    address static public auction;
    address static public lotReciever;

    uint256 static public amountHash;
    uint128 public amount;
    uint256 public secret;

    // here can be any additional information

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == auction, 102);
    }

    function reveal(
        uint128 amount_,
        uint256 secret_
    ) public {
        require(secret == 0, 103);
        require(tvm.pubkey() == msg.pubkey(), 102);
    
        // require(tvm.checkSign(?????), 201);

        require(address(this).balance >= amount + 2);
        tvm.accept();

        amount = amount_;
        secret = secret_;

        TvmBuilder builder;
        builder.store(
            startTime,
            biddingDuration,
            revealingDuration,
            transferDuration,
            root,
            auction,
            lotReciever,
            amountHash
        );
        TvmCell data = builder.toCell();

        IAuction(auction).revealBid(secret, amount, data);
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
}
