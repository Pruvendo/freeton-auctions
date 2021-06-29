/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid is BidInterface {

    uint256 static public rootPubKey;
    uint static public b_id;

    uint128 public amount;
    bool public frozen;

    // here can be any additional information

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
        frozen = true;
    }

    function unfreeze(uint128 amountArg) override external {
        amount = amountArg;
        frozen = false;
    }

    function transferRemainsTo(address destination) override external {
        // require auctionRoot or auction
        require(!frozen);
        destination.transfer(address(this).balance - amount - 1 ton, false);
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
