/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

contract __HashCalc {
    function calc(uint128 amount) public pure returns (TvmCell) {
        tvm.accept();
        TvmBuilder builder;
        builder.store(
            amount
        );
        return builder.toCell();
    }
}