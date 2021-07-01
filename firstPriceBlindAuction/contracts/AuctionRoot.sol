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
    address lotReciever;

    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    bool ended;
}

contract AuctionRoot is IRoot {

    mapping(address => AuctionScenarioData) public auctions;
    uint public number_of_auctions;
    
    uint static public rootId;

    TvmCell static public auctionCode;
    TvmCell static public giverCode;
    TvmCell static public bidCode;

    constructor(
        TvmCell auctionCode_,
        TvmCell giverCode_,
        TvmCell bidCode_,
        uint rootId_
    ) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();

        auctionCode = auctionCode_;
        giverCode = giverCode_;
        bidCode = bidCode_;
        rootId = rootId_;
    }

    function startAuctionScenario(
        uint prize, // nope
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) public returns (address auctionAddress) {
        require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > now, 103);
        require(biddingDuration > 0, 103);
        require(revealingDuration > 0, 103);
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
            lotReciever: emptyAddress,
            startTime: startTime,
            biddingDuration: biddingDuration,
            revealingDuration: revealingDuration,
            ended: false
        });
        auctions[auctionAddress] = auctionScenarioData;
        number_of_auctions += 1;
        return auctionAddress;
    }

    function continueAuctionScenario(address auctionAddress) public {
        require(tvm.pubkey() == msg.pubkey(), 102);
        require(auctions.exists(auctionAddress), 101);
        AuctionScenarioData auctionScenario = auctions[auctionAddress];
        require(auctionScenario.ended == false, 101);
        require(
            now > (auctionScenario.startTime
                + auctionScenario.biddingDuration
                + auctionScenario.revealingDuration), 103
        );
        tvm.accept();

        IAuction(auctionAddress).endAuction();
    }

    function setWinner(address winnerBid, address lotReciever) override external {
        require(auctions.exists(msg.sender), 102);
        require(auctions[msg.sender].ended == false, 101);

        tvm.accept();
        auctions[msg.sender].winnerBid = winnerBid;
        auctions[msg.sender].lotReciever = lotReciever;

        // transfer money <-> prize
        AuctionScenarioData auction = auctions[msg.sender];
        IGiver(auction.giver).transferTo(auction.lotReciever);
        IBid(auction.winnerBid).transferBidTo(auction.bidReciever);

        auctions[msg.sender].ended = true;
    }

    function deployAuction(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) private inline returns (address newAuction) {
        newAuction = new Auction {
            code: auctionCode,
            value: 10 ton,
            pubkey: publicKey,
            varInit: {
                startTime: startTime,
                biddingDuration: biddingDuration,
                revealingDuration: revealingDuration,
                bidCode: bidCode,
                root: this,
                a_id: number_of_auctions
            }
        }();
    }

    function deployGiver(uint prize) private inline returns (address newGiver) {
        newGiver = new Giver {
            code: giverCode,
            value: 10 ton,
            pubkey: tvm.pubkey(),
            varInit: {
                prize: prize,
                root: this,
                g_id: number_of_auctions
            }
        }();
    }
}
