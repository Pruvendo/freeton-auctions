/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";

contract Giver is IGiver {

    address public root;
    uint public endTime;

    constructor(address root_, uint endTime_) public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);

        root = root_;
        endTime = endTime_;
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
