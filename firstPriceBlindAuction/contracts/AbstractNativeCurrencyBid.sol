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
        if(activeDepool != address(0)) {
            selfdestruct(destination);
        }
        else {
            terminationStarted = true;
        }
    }

    function __transferTo(address destination) internal inline {
        if(activeDepool != address(0)) {
            amountToSendExternally = amount;
            dest = destination;
            ended = true;
        }
        else {
            destination.transfer(amount, false);
        }
    }

    function canRevealBid()
    internal inline returns (bool) {
        return (activeDepool != address(0) && amountDeposited >= amount) || (address(this).balance >= amount + 3 ton);
    }

    function setUpRevealBidData(TvmCell data) internal inline {}

    receive() external {
        require(false, 104);
    }
}
