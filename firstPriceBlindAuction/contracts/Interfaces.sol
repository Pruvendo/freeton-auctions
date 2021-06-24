/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface AucInterface {
    function endAuction() external responsible returns (address);
}

interface RootInterface {
    function setWinner(address winnerBid) external;
}

interface BidInterface {
    function transferTo(address destination) external;
}

interface GiverInterface {
    function transferTo(address destination) external;
}
