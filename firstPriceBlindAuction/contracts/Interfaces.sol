/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface IAuction {
    function end() external;
    
    // revealBid has to be called by Bid instance only
    // (and revealBid check's Bid contract's code)
    function revealBid(uint256 secret, uint128 amount, TvmCell data) external;
}

interface IRoot {
    // IAuction calls setWinner and forces lot <-> bid exchange
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
    // this method has to be allowed for the root contract only
    function transferTo(address destination) external;
}

// IBid has to be able to call IAuction.revealBid
interface IBid is IGiver {

    //can be called only by deployer and only after transfer stage
    function transferRemainsTo(address destination) external;
}
