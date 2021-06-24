/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract Bid {

    uint256 static public rootPubKey;

    // here can be any additional information

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    function transferTo(address destination) public {
        // auctionRoot or auction
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
