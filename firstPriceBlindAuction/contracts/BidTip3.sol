/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "Tip3Interfaces.sol";

contract Bid is IGiver, IBid, ITip3Holder {
    uint public startTime;
    uint public biddingDuration;
    uint public revealingDuration;
    uint public transferDuration;

    address public root;
    address public auction;
    address public lotReciever;

    uint256 public amountHash;
    uint256 public secret;
    uint128 public amount;

    uint128 public balance;
    address public wallet;

    constructor(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address root_,
        address auction_,
        address lotReciever_,

        // some data to verify onTip3LendOwnership calls
        uint256 amountHash_,
        address wallet_

    ) public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);

        startTime = startTime_;
        biddingDuration = biddingDuration_;
        revealingDuration = revealingDuration_;
        transferDuration = transferDuration_;
        root = root_;
        auction = auction_;
        lotReciever = lotReciever_;
        amountHash = amountHash_;

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
        // TODO сторонний пользователь может просаживать баланс!!!
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

    function reveal(TvmCell data) override external {
        require(secret == 0, 103);
        require(tvm.pubkey() == msg.pubkey(), 102);
        require(now >= startTime + biddingDuration, 103);
        require(now < startTime + biddingDuration + revealingDuration, 103);

        (uint128 amount_, uint256 secret_) = data.toSlice().decode(uint128, uint256);

        TvmBuilder builder;
        builder.store(
            secret_,
            amount_
        );
        uint256 hash_ = tvm.hash(builder.toCell());
        require(amountHash == hash_, 201);

        require(address(this).balance >= amount + 3 ton);

        tvm.accept();

        amount = amount_;
        secret = secret_;

        IAuction(auction).revealBid{value: 1 ton}({
            amount_: amount,

            secret_: secret,
            startTime_: startTime,
            biddingDuration_: biddingDuration,
            revealingDuration_: revealingDuration,
            transferDuration_: transferDuration,
            amountHash_: amountHash,

            root_: root,
            auction_: auction,
            lotReciever_: lotReciever
        });
    }
}
