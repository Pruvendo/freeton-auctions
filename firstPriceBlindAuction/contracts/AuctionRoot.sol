/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Auction.sol";
import "Bid.sol";
import "Giver.sol";
import "Interfaces.sol";

struct AuctionScenarioData {
    uint256 auctionPubKey;

    address giver;
    address bidReciever;
    address winnerBid;
    address prizeReciever;

    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    bool ended;
}

contract AuctionRoot is RootInterface {

    mapping(address => AuctionScenarioData) public auctions;
    uint public number_of_auctions;
    
    uint static public rootId;

    TvmCell static public auctionCode;
    TvmCell static public giverCode;
    TvmCell static public bidCode;

    constructor(
        TvmCell auctionCodeArg,
        TvmCell giverCodeArg,
        TvmCell bidCodeArg,
        uint rootIdArg
    ) public {
        // require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();

        auctionCode = auctionCodeArg;
        giverCode = giverCodeArg;
        bidCode = bidCodeArg;
        rootId = rootIdArg;
    }

    function startAuctionScenario(
        uint prize, // nope
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) public returns (address auctionAddress) {
        // require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > tx.timestamp);
        // require(biddingDuration > 0);
        // require(revealingDuration > 0);
        tvm.accept();

        auctionAddress = deployAuction(
            startTime,
            biddingDuration,
            revealingDuration,
            publicKey
        );
        address giverAddress = deployGiver(prize);
        address emptyAddress;
        AuctionScenarioData auctionScenarioData = AuctionScenarioData({
            auctionPubKey: publicKey,
            giver: giverAddress,
            bidReciever: bidReciever,
            winnerBid: emptyAddress,
            prizeReciever: emptyAddress,
            startTime: startTime,
            biddingDuration: biddingDuration,
            revealingDuration: revealingDuration,
            ended: false
        });
        auctions[auctionAddress] = auctionScenarioData;
        return auctionAddress;
    }

    function continueAuctionScenario(address auctionAddress) public {
        // require(tvm.pubkey() == msg.pubkey(), 102);
        require(auctions.exists(auctionAddress), 199);
        AuctionScenarioData auctionScenario = auctions[auctionAddress];
        require(auctionScenario.ended == false, 194);
        // require(
        //     tx.timestamp > (auctionScenario.startTime
        //         + auctionScenario.biddingDuration
        //         + auctionScenario.revealingDuration)
        // );
        tvm.accept();

        AucInterface(auctionAddress).endAuction();
    }

    function setWinner(address winnerBid, address prizeReciever) override external {
        require(auctions.exists(msg.sender), 198);
        // require(auctionScenario.auctionPubKey == msg.pubkey(), 197);
        // emit Debug(auctions[msg.sender].ended);
        require(auctions[msg.sender].ended == false, 150);
        // AuctionScenarioData auctionScenario = auctions[msg.sender];
        // require(auctionScenario.ended == false, 194);
        tvm.accept();
        auctions[msg.sender].winnerBid = winnerBid;
        auctions[msg.sender].prizeReciever = prizeReciever;

        // transfer money <-> goods
        AuctionScenarioData auction = auctions[msg.sender];
        GiverInterface(auction.giver).transferTo(auction.prizeReciever);
        BidInterface(auction.winnerBid).transferBidTo(auction.bidReciever);

        auctions[msg.sender].ended = true;
    }

    function deployAuction(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) private inline returns (address newAuction) {
        // require...

        newAuction = new Auction {
            code: auctionCode,
            value: 10 ton,
            pubkey: publicKey,
            varInit: {
                startTime: startTime,
                biddingDuration: biddingDuration,
                revealingDuration: revealingDuration,
                bidCode: bidCode,
                rootPubKey: tvm.pubkey(),
                a_id: number_of_auctions
            }
        }();
        number_of_auctions += 1;
    }

    function deployGiver(uint prize) private inline returns (address newGiver) {
        newGiver = new Giver {
            code: giverCode,
            value: 10 ton,
            pubkey: tvm.pubkey(),
            varInit: {
                prize: prize
            }
        }();
    }

    function renderHelloWorld() public pure returns (string) {
        require(msg.value == 0 ton, 200);
        return "Hello World";
    }
}
