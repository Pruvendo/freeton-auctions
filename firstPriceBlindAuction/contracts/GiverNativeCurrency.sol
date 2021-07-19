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
    address static public root;

    constructor(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,
        address root_
    ) public {
        require(tvm.pubkey() != 0, 101);

        startTime = startTime_;
        biddingDuration = biddingDuration_;
        revealingDuration = revealingDuration_;
        transferDuration = transferDuration_;
        root = root_;
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

        destination.transfer({
            value: 0 ton,
            bounce: false,
            flag: 128
        });
    }
}
