/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";

abstract contract Depoolable {

    uint64 constant MIN_BID_BALANCE = 1 ton;
    uint64 constant MIN_DEPOOL_EXIT_BALANCE = 1 ton;

    uint32 constant ERROR_DEPOOL_NOT_REGISTERED = 131;
    uint32 constant ERROR_DEPOOL_NOT_ENOUGH_VALUE = 132;
    uint32 constant ERROR_DEPOOL_NOT_ACTIVE = 133;
    uint32 constant ERROR_DEPOOL_NOT_AUTHORIZED = 134;
    uint32 constant ERROR_DEPOOL_NOT_INITIZALIZED = 135;

    mapping (address => uint64) public static depools;
    address public static owner;

    address public activeDepool;
    bool public initialized;
    bool public ended;
    bool public terminationStarted;
    uint64 public amountToSendExternally;
    address public depooledParticipant;
    address public destination;

    function calcRequiredDepoolBalance() private inline returns (uint8, uint64) {
        uint64 result = 0;
        uint8 count = 0;
        optional(address, uint64) depool = depools.min();
        while(depool.hasValue()) {
            (address addr, uint64 minStake) = depool.get();
            result += minStake;
            count++;
            depool = depools.next(addr);
        }
        return (count, result);
    }

    function calcRequiredBalance() private inline returns (uint64) {
        (uint8 count, uint64 depoolStakes) = calcRequiredDepoolBalance();
        return MIN_BID_BALANCE + depoolStakes + count * MIN_DEPOOL_EXIT_BALANCE;
    }

    function participateInDepools() private inline {
        optional(address, uint64) depool = depools.min();
        while(depool.hasValue()) {
            (address addr, uint64 minStake) = depool.get();
            IDePool(addr).addOrdinaryStake(minStake);
            depool = depools.next(addr);
        }
    }

    function init() external {
        require(msg.value >= calcRequiredBalance(), ERROR_DEPOOL_NOT_ENOUGH_VALUE);
        require(msg.sender == owner, ERROR_DEPOOL_NOT_AUTHORIZED);
        tvm.accept();
        participateInDepools();
        initialized = true;
    }

    function onTransfer(address source, uint128 amount) external {
        require(initialized, ERROR_DEPOOL_NOT_INITIZALIZED);
        require(depools.exists(msg.sender), ERROR_DEPOOL_NOT_REGISTERED);
        require(activeDepool == address(0) || activeDepool == msg.sender, ERROR_DEPOOL_NOT_ACTIVE);
        tvm.accept();
        activeDepool = msg.sender;
        depooledParticipant = source;
    }

    function onRoundComplete(
        uint64 roundId,
        uint64 reward,
        uint64 ordinaryStake,
        uint64 vestingStake,
        uint64 lockStake,
        bool reinvest,
        uint8 reason) external {
        require(depools.exists(msg.sender), ERROR_DEPOOL_NOT_REGISTERED);
        tvm.accept();

        if(terminationStarted){
            delete depools[msg.sender];
            if(!depools.min().hasValue()) {
                selfdestruct(owner);
            }
        }
        else if(ended && msg.sender == activeDepool) {
            uint128 realAmountToSend = math.min(msg.value, amountToSendExternally);
            if(realAmountToSend > 0) {
                destination.transfer(realAmountToSend, false, 1);
            }
            IDePool(msg.sender).transferStake(depooledParticipant, ordinaryStake - depools.fetch(msg.sender).get());
            initiateTermination();
        }
    }

    function initiateTermination() private {
        terminationStarted = true;
        optional(address, uint64) depool = depools.min();
        if(!depool.hasValue()) {
            selfdestruct(owner);
        }
        while(depool.hasValue()) {
            (address addr, uint64 minStake) = depool.get();
            IDePool(addr).withdrawAll();
            depool = depools.next(addr);
        }
    }
}