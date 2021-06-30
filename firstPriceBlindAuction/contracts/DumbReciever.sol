/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract DumbReciever {
    uint static public id;

    constructor(uint idArg) public {
        tvm.accept();
        id = idArg;
    }
}