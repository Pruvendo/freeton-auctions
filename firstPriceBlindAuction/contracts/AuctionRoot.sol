/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Auction.sol";
import "Bid.sol";
import "Giver.sol";

struct AuctionData {
    address auction;
    address giver;
    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    address winnerBid;
}

contract AuctionRoot {

    AuctionData[] public auctions;
    // other contracts code

    constructor(
        // other contracts code
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    function startAuction(
        uint prize, // nope
        uint startTime,
        uint biddingDuration,
        uint revealingDuration
    ) public returns (uint) {
        require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > tx.timestamp);
        require(biddingDuration > 0);
        require(revealingDuration > 0);
        
        address auctionAddress = deployAuction(
            startTime,
            biddingDuration,
            revealingDuration
        );
        address giverAddress = deployGiver(prize);
        address winnerBid;
        AuctionData auctionData = AuctionData(
            auctionAddress,
            giverAddress,
            startTime,
            biddingDuration,
            revealingDuration,
            winnerBid
        );
        auctions.push(auctionData);
        return auctions.length - 1;
    }

    function continueAuctionScenario(uint auctionId) public {
        require(auctionId < auctions.length, 102);
        setWinner(auctions[auctionId]);

        AuctionData auction = auctions[auctionId];

        // transfer money <-> goods
    }

    function deployAuction(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration
    ) private inline returns (address) {
        // https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.md
    }

    function deployGiver(uint prize) private inline returns (address) {
        // https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.md
    }

    function setWinner(AuctionData auction) private inline {
        require(
            tx.timestamp > (auction.startTime
                + auction.biddingDuration
                + auction.revealingDuration)
        );

        //request to the Auction contract if the winner not known
    }
}
