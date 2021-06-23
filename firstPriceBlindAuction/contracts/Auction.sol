/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Bid.sol";
import "Interfaces.sol";

struct BidData {
    address bid;
    uint amount;
    uint256 bidderPubKey;
}

contract Auction is AucInterface {

    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    uint static public id;
    TvmCell static public bidCode;
    uint256 static public rootPubKey;

    BidData[] public bids;

    // constructor() public {
    //     // require(tvm.pubkey() != 0, 101);
    //     // require(msg.pubkey() == tvm.pubkey(), 102);

    //     // require(0 != 0, 111);

    //     tvm.accept();
    // }

    function makeBid(uint256 encriptedAmount) public returns (address bid) {

    }

    function revealBid(uint256 secret) public {
        
    }

    function endAuction() override public responsible returns (address, uint) {
        
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
