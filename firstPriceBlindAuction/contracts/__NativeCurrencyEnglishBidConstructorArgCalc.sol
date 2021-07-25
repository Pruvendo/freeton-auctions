/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

contract __HashCalc {
    function calc(
        uint startTime_,
        uint biddingDuration_,
        uint transferDuration_,

        address root_,
        address auction_,
        address lotReciever_
    ) public pure returns (TvmCell, TvmCell) {
        tvm.accept();

        TvmBuilder builder1;
        builder1.store(
            startTime_,
            biddingDuration_,
            transferDuration_
        );

        TvmBuilder builder2;
        builder2.store(
            root_,
            auction_,
            lotReciever_
        );


        TvmBuilder builderFinal;
        builderFinal.store(
            builder1.toCell(),
            builder2.toCell()
        );

        TvmCell _;

        return (builderFinal.toCell(), _);
    }
}