/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "Tip3Interfaces.sol";

contract Bid is IGiver, ITip3Holder {
    uint public startTime;
    uint public biddingDuration;
    uint public revealingDuration;
    uint public transferDuration;

    address public root;

    uint128 public balance;
    address public wallet;

    constructor(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address root_,

        address wallet_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);

        startTime = startTime_;
        biddingDuration = biddingDuration_;
        revealingDuration = revealingDuration_;
        transferDuration = transferDuration_;
        root = root_;

        balance = 0;
        wallet = wallet_;
    }

    function onTip3LendOwnership(
        uint128 lend_balance,
        uint32 lend_finish_time,
        uint256 wallet_public_key_,
        address owner_addr,
        TvmCell payload,
        address answer_addr
    ) override external {
        require(verify(wallet_public_key_, owner_addr, payload, answer_addr), 102);
        require(lend_finish_time >= startTime + biddingDuration + revealingDuration + transferDuration, 103);
        tvm.accept();
        balance += lend_balance;
    }

    function verify(
        uint256 wallet_public_key_,
        address owner_addr,
        TvmCell payload,
        address answer_addr
    ) private inline pure returns (bool) {

        //https://github.com/tonlabs/flex/blob/main/flex/Price.cpp#L303

        return true;
    }

    function transferTo(address destination) override external {
        require(msg.sender == root, 102);
        tvm.accept();

        ITip3Wallet(wallet).transfer({
            dest: destination,
            tokens: balance,
            return_ownership: true,
            answer_addr: destination
        });
    }
}
