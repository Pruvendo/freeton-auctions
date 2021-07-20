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
            "Let me take you down, cos I'm going to Strawberry Fields Nothing is real and nothing to get hung about Strawberry Fields forever",
            amount
        );
        return tvm.hash(builder.toCell());
    }
}