/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Auction.sol";
import "Bid.sol";
import "Giver.sol";

struct AuctionScenarioData {
    address auction;
    address giver;
    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    address winnerBid;
}

contract AuctionRoot {

    AuctionScenarioData[] public auctions;

    TvmCell static public auctionCode;
    TvmCell static public auctionData;
    TvmCell  public bidCode;
    TvmCell  public giverCode;

    constructor(TvmCell code, TvmCell data) public {
        // require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();

        auctionCode = code;
        auctionData = data;
    }

    function startAuctionScenario(
        uint prize, // nope
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) public returns (uint) {
        // require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > tx.timestamp);
        require(biddingDuration > 0);
        require(revealingDuration > 0);
        tvm.accept();

        address auctionAddress = deployAuction(
            startTime,
            biddingDuration,
            revealingDuration,
            publicKey
        );
        address giverAddress = deployGiver(prize);
        address winnerBid;
        AuctionScenarioData auctionScenarioData = AuctionScenarioData(
            auctionAddress,
            giverAddress,
            startTime,
            biddingDuration,
            revealingDuration,
            winnerBid
        );
        auctions.push(auctionScenarioData);
        return auctions.length - 1;
    }

    function continueAuctionScenario(uint auctionId) public {
        require(auctionId < auctions.length, 102);
        setWinner(auctions[auctionId]);

        AuctionScenarioData auction = auctions[auctionId];

        // transfer money <-> goods
    }

    function deployAuction(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) private inline returns (address newAuction) {
        // https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.md
        newAuction = new Auction{
            code: auctionCode,
            value: 10 ton,
            pubkey: publicKey,
            varInit: {
                startTime: startTime,
                biddingDuration: biddingDuration,
                revealingDuration: revealingDuration,
                rootPubKey: tvm.pubkey()
            }
        }();

        auctions.push();
        address giverAddress;
        address winnerBid;
        auctions[auctions.length - 1] = AuctionScenarioData(
            newAuction,
            giverAddress,
            startTime,
            biddingDuration,
            revealingDuration,
            winnerBid
        );
    }

    function deployGiver(uint prize) private inline returns (address) {
        // https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.md
    }

    function setWinner(AuctionScenarioData auction) private inline {
        require(
            tx.timestamp > (auction.startTime
                + auction.biddingDuration
                + auction.revealingDuration)
        );

        //request to the Auction contract if the winner not known
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
