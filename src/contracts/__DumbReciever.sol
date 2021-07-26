/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract __DumbReciever {

    constructor() public {
        tvm.accept();
    }
}