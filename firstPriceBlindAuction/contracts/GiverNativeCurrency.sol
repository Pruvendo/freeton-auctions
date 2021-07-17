/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";

contract Giver is IGiver {

    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    uint static public transferDuration;
    uint128 public amount;
    address static public root;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
    }

    function transferRemainsTo(address destination) override external {
        require(tvm.pubkey() == msg.pubkey(), 102);
        require(
            now >= (startTime + biddingDuration + revealingDuration + transferDuration),
            103
        );
        tvm.accept();

        destination.transfer({
            value: 0 ton,
            bounce: false,
            flag: 128
        });
    }

    function transferTo(address destination) override external {
        require(msg.sender == root, 102);
        tvm.accept();

        destination.transfer(amount, false);
    }
}
