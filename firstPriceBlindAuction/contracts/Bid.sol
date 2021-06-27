/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid is BidInterface {

    uint256 static public rootPubKey;
    uint static public b_id;

    // here can be any additional information

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    function transferTo(address destination) override external {
        // require auctionRoot or auction

        destination.transfer(0 ton, false, 128);
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
