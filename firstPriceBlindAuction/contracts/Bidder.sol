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
        AucInterface(auction).makeBid{
            value: 0 ton,
            flag: 128 + 64
        }(amountHash);
    }
}