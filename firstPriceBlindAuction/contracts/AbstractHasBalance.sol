/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

abstract contract AHasBalance {
    uint128 public amount;
    uint128 public balance;
    uint128 public minBalance;
}