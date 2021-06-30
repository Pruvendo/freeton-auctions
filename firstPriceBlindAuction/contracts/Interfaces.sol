/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface AucInterface {
    function endAuction() external returns (address);
    function makeBid(uint256 amountHash, address prizeReciever) external returns (address bid);
    function revealBid(bytes signature, uint128 amount) external;
    function takeBidBack(address destination) external;
}

interface RootInterface {
    function setWinner(address winnerBid, address bidReciever) external;
}

interface BidInterface {
    function unfreeze(uint128 amount) external;
    function transferRemainsTo(address destination) external;
    function transferBidTo(address destination) external;
}

interface GiverInterface {
    function transferTo(address destination) external;
}
