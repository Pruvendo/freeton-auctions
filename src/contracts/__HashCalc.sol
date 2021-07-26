/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

contract __HashCalc {
    function calc(uint128 amount, uint256 secret) public pure returns (uint256) {
        tvm.accept();
        TvmBuilder builder;
        builder.store(
            secret,
            amount
        );
        return tvm.hash(builder.toCell());
    }
}