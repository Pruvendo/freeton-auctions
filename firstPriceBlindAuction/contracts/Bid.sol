/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid is BidInterface {

    // uint256 static public rootPubKey;
    uint static public b_id;
    address static public prizeReciever;
    address static public root;
    address static public auction;

    uint128 public amount;
    bool public frozen;

    // here can be any additional information

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == auction, 102);

        tvm.accept();
        frozen = true;
    }

    function unfreeze(uint128 amountArg) override external {
        require(msg.sender == root || msg.sender == auction, 102);

        amount = amountArg;
        frozen = false;
    }

    function transferRemainsTo(address destination) override external {
        require(msg.sender == root || msg.sender == auction, 102);
        require(!frozen);
        destination.transfer(address(this).balance - amount - 2 ton, false);
    }

    function transferBidTo(address destination) override external {
        require(msg.sender == root || msg.sender == auction, 102);

        require(!frozen);
        destination.transfer(amount, false);
    }
}
