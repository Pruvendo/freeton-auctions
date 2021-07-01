/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid is IBid {

    // uint256 static public rootPubKey;
    uint static public b_id;
    address static public lotReciever;
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

    function unfreeze(uint128 amount_) override external {
        require(msg.sender == root || msg.sender == auction, 102);

        amount = amount_;
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
