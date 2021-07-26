/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;

interface ITip3Wallet {
    function lendOwnership(
        uint256 std_dest,
        uint128 lend_balance,
        uint32 lend_finish_time,
        TvmCell deploy_init_cl,
        TvmCell payload
    ) external returns (bool);

    function transfer(
        address dest,
        uint128 tokens,
        bool return_ownership,
        address answer_addr
    ) external;
}

interface ITip3Holder {
    function onTip3LendOwnership(
        uint128 lend_balance,
        uint32 lend_finish_time,
        uint256 wallet_public_key_,
        address owner_addr,
        TvmCell payload,
        address answer_addr
    ) external;
}