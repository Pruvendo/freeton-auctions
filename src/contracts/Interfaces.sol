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

        // auction-type specific data
        TvmCell auctionData,

        address root_,
        address auction_,
        address lotReciever_
    ) external;

    function getInfo() external view returns(address bidGiver_, address lotReciever_, uint128 winnersPrice_);
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
}

interface IGiver {
    // this method has to be allowed for the root contract only
    function transferTo(address destination) external;
}

interface IDoubleGiver {
    // this method has to be allowed for the root contract only
    function transferTo(address moneyDestination, address resourceDestination) external;
}

interface IBackTransferable {
    function transferRemainsTo(address destination) external;
}

interface IBid {
    function reveal(TvmCell bidData, TvmCell auctionData) external;
}

interface IDePool {
    function addOrdinaryStake(uint64 stake) external;
    function transferStake(address dest, uint64 amount) external;
    function withdrawAll() external;
}