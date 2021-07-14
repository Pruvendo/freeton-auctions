/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface IAuction {
    function end() external;
    function revealBid(uint256 secret, uint128 amount, TvmCell data) external;
}

interface IRoot {
    function setWinner(
        address bidGiver,
        address lotGiver,
        address bidReciever,
        address lotReciever,
        TvmCell data
    ) external;

    function startAuctionScenario(
        address lotGiver,
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint transferDuration
    ) external returns (address auctionAddress);
}

interface IGiver {
    function transferTo(address destination) external;
}

interface IBid is IGiver {
    function transferRemainsTo(address destination) external;
}
