/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasAmount.sol";
import "Tip3Interfaces.sol";

abstract contract AT3Bid is AHasAmount {

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

    function __transferTo(address destination) internal inline {
        ITip3Wallet(wallet).transfer({
            dest: destination,
            tokens: balance,
            return_ownership: true,
            answer_addr: destination
        });
    }

    function canRevealBid()
    internal inline returns (bool) {
        return (address(this).balance >= 2 ton) && (balance >= amount);
    }

    function setUpRevealBidData(TvmCell data) internal inline {}
}
