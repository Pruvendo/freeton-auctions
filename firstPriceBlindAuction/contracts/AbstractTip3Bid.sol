/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasBalance.sol";
import "Tip3Interfaces.sol";

abstract contract AT3Bid is AHasBalance, ITip3Holder {

    uint128 public balance;
    address public wallet;

    function correctConstructorsBidData()
    internal inline returns (bool) {
        return true;
    }

    function setUpBidSpecificDataConstructor(TvmCell bidData) internal inline {
        balance = 0;
        (wallet) = bidData.toSlice().decode(address);
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

    function __transferTo(address destination) internal inline {
        ITip3Wallet(wallet).transfer({
            dest: destination,
            tokens: balance,
            return_ownership: true,
            answer_addr: destination
        });
    }

    function __transferRemains(address destination) internal inline {
        selfdestruct(destination);
    }

    function canRevealBid()
    internal inline returns (bool) {
        return (address(this).balance >= 2 ton) && (balance >= amount);
    }

    function setUpRevealBidData(TvmCell data) internal inline {}
}
