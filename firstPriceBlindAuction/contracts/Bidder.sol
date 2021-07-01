/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bidder {

    uint256 static public amountHash;
    address static public auction;
    address static public lotReciever;

    constructor(uint256 amountHash_, address auction_, address reciever_) public {
        require(tvm.pubkey() != 0, 101);
        amountHash = amountHash_;
        auction = auction_;
        lotReciever = reciever_;
        tvm.accept();

        // IAuction(auction).makeBid{
        //     value: 0 ton,
        //     flag: 128 + 64
        // }(amountHash);
    }

    function toBid() public {
        tvm.accept();

        uint128 val = msg.value + address(this).balance - (2 ton);

        IAuction(auction).makeBid{
            value: val
        }(amountHash, lotReciever);
    }

    function toReveal(uint128 amount) public {
        tvm.accept();
        IAuction(auction).revealBid(
            "0000000000000000000000000000000000000000000000000000000000000000",
            amount
        );
    }

    function takeBidBack() public {
        //require...

        tvm.accept();
        IAuction(auction).takeBidBack(this);
    }
}