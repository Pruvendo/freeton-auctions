/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Auction {
    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    uint256 static public rootPubKey;

    constructor() public {
        // require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        // require(0 != 0, 111);

        tvm.accept();
    }

    function makeBid(uint256 encriptedAmount) public returns (address bid) {

    }

    function revealBid(uint256 secret) public {
        
    }

    function endAuction() public returns (address winnerBid) {

    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
