/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Giver is GiverInterface {
    
    uint static public prize;
    uint static public g_id;
    address static public root;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root, 102);

        tvm.accept();
    }

    function transferTo(address destination) override external {
        require(msg.sender == root, 102);

        destination.transfer(0 ton, false, 128);
    }
}
