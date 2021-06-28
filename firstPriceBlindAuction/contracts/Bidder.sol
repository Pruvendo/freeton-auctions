/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bidder {

    uint256 static public amountHash;
    address static public auction;

    constructor(uint256 amountHashX, address auctionX) public {
        amountHash = amountHashX;
        auction = auctionX;
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
        }(amountHash);
    }

    function toReveal(uint amount) public {
        tvm.accept();
        AucInterface(auction).revealBid(
            "0000000000000000000000000000000000000000000000000000000000000000",
            amount
        );
    }
}