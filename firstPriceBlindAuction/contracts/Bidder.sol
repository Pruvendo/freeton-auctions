/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bidder {

    uint256 static public amountHash;
    address static public auction;
    address static public prizeReciever;

    constructor(uint256 amountHashArg, address auctionArg, address recieverArg) public {
        require(tvm.pubkey() != 0, 101);
        amountHash = amountHashArg;
        auction = auctionArg;
        prizeReciever = recieverArg;
        tvm.accept();

        // AucInterface(auction).makeBid{
        //     value: 0 ton,
        //     flag: 128 + 64
        // }(amountHash);
    }

    function toBid() public {
        tvm.accept();

        uint128 val = msg.value + address(this).balance - (2 ton);

        AucInterface(auction).makeBid{
            value: val
        }(amountHash, prizeReciever);
    }

    function toReveal(uint128 amount) public {
        tvm.accept();
        AucInterface(auction).revealBid(
            "0000000000000000000000000000000000000000000000000000000000000000",
            amount
        );
    }

    function takeBidBack() public {
        //require...

        tvm.accept();
        AucInterface(auction).takeBidBack(this);
    }
}