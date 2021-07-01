/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface IAuction {
    function endAuction() external;
    function makeBid(uint256 amountHash, address lotReciever) external returns (address bid);
    function revealBid(bytes signature, uint128 amount) external;
    function takeBidBack(address destination) external;
}

interface IRoot {
    function setWinner(address winnerBid, address bidReciever) external;
}

interface IBid {
    function unfreeze(uint128 amount) external;
    function transferRemainsTo(address destination) external;
    function transferBidTo(address destination) external;
}

interface IGiver {
    function transferTo(address destination) external;
}
