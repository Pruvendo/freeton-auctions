/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;

interface IAuction {
    function end() external;
    
    // revealBid has to be called by Bid instance only
    // (and revealBid check's Bid contract's code)
    // Here's the formal difference between Bid and Giver
    function revealBid(
        uint128 amount_,
        
        uint256 secret_,
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,
        uint256 amountHash_,
        
        address root_,
        address auction_,
        address lotReciever_
    ) external;

    function getUpdateableInfo() external view returns(
        address bidGiver,
        address lotReciever,
        uint128 amount,
        bool ended
    );

    function getAllInfo() external view returns(
        uint startTime_,
        uint biddingDuration_,
        uint revealingDuration_,
        uint transferDuration_,

        address lotGiver_,
        address bidReciever_,

        address bidGiver_,
        address lotReciever_,
        uint128 amount_,

        address root_,
        bool ended_
    );
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

interface IBackTransferable {
    function transferRemainsTo(address destination) external;
}

interface IBid {
    function reveal(TvmCell data) external;
}