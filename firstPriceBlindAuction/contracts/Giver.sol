/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Giver {
    
    uint static public prize;

    constructor() public {
        // require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    function transferTo(address destination) public {
        require(msg.pubkey() == tvm.pubkey(), 102);


    }
}
