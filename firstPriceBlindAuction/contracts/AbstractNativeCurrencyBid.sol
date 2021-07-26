/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "AbstractHasBalance.sol";
import "Depoolable.sol";

abstract contract ANCBid is AHasBalance, Depoolable {

    function correctConstructorsBidData()
    internal inline returns (bool) {
        return true;
    }

    function setUpBidSpecificDataConstructor(TvmCell bidData) internal inline {}

    function __transferRemains(address destination) internal inline {
        selfdestruct(destination);
    }

    function __transferTo(address destination) internal inline {
        destination.transfer(amount, false);
    }

    function canRevealBid()
    internal inline returns (bool) {
        return (address(this).balance >= amount + 3 ton);
    }

    function setUpRevealBidData(TvmCell data) internal inline {}
}
