/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasBalance.sol";
import "Tip3Interfaces.sol";

abstract contract AReversedTip3NativeBid is AHasBalance, ITip3Holder {

    address public wallet;
    address public owner;

    function correctConstructorsBidData()
    internal inline returns (bool) {
        return true;
    }

    function setUpBidSpecificDataConstructor(TvmCell bidData) internal inline {
        balance = 0;
        (minBalance, wallet, owner) = bidData.toSlice().decode(uint128, address, address);
    }

    function onTip3LendOwnership(
        uint128 lend_balance,
        uint32 lend_finish_time,
        uint256 wallet_public_key_,
        address owner_addr,
        TvmCell payload,
        address answer_addr
    ) override external {
        require(owner_addr == owner, 102);
        tvm.accept();
        balance += lend_balance;
    }

    function __transferTo(address moneyDestination, address resourceDestination) internal inline {

        ITip3Wallet(wallet).transfer({
            dest: resourceDestination,
            tokens: balance,
            return_ownership: true,
            answer_addr: resourceDestination
        });

        moneyDestination.transfer(amount, false);
    }

    function __transferRemains(address destination) internal inline {
        selfdestruct(destination);
    }

    function canRevealBid() internal inline returns (bool) {
        return (address(this).balance - 2 ton >= amount) && (balance >= minBalance);
    }

    function setUpRevealBidData(TvmCell data) internal inline {}
}
