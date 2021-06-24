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
    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    address winnerBid;
    bool ended;
}

contract AuctionRoot is RootInterface {

    mapping(address => AuctionScenarioData) public auctions;

    TvmCell static public auctionCode;
    TvmCell static public giverCode;
    TvmCell static public bidCode;

    constructor(
        TvmCell auctionCodeArg,
        TvmCell giverCodeArg,
        TvmCell bidCodeArg
    ) public {
        // require(tvm.pubkey() != 0, 101);
        // require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();

        auctionCode = auctionCodeArg;
        giverCode = giverCodeArg;
        bidCode = bidCodeArg;
    }

    function startAuctionScenario(
        uint prize, // nope
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) public returns (address auctionAddress) {
        // require(msg.pubkey() == tvm.pubkey(), 102);
        require(startTime > tx.timestamp);
        require(biddingDuration > 0);
        require(revealingDuration > 0);
        tvm.accept();

        auctionAddress = deployAuction(
            startTime,
            biddingDuration,
            revealingDuration,
            publicKey
        );
        address giverAddress = deployGiver(prize);
        address winnerBid;
        AuctionScenarioData auctionScenarioData = AuctionScenarioData(
            publicKey,
            giverAddress,
            startTime,
            biddingDuration,
            revealingDuration,
            winnerBid,
            false
        );
        auctions[auctionAddress] = auctionScenarioData;
        return auctionAddress;
    }

    function continueAuctionScenario(address auctionAddress) public {
        // require(tvm.pubkey() == msg.pubkey(), 102);
        require(auctions.exists(auctionAddress), 102);
        AuctionScenarioData auctionScenario = auctions[auctionAddress];
        require(
            tx.timestamp > (auctionScenario.startTime
                + auctionScenario.biddingDuration
                + auctionScenario.revealingDuration)
        );
        tvm.accept();

        AucInterface(auctionAddress).endAuction{callback: AuctionRoot.setWinner}();

        // transfer money <-> goods
    }

    function setWinner(address winnerBid) override external {
        require(auctions.exists(msg.sender), 102);
        AuctionScenarioData auctionScenario = auctions[msg.sender];
        require(auctionScenario.auctionPubKey == msg.pubkey(), 102);
        require(auctionScenario.ended == false, 102);

        auctionScenario.winnerBid = winnerBid;
        auctionScenario.ended = true;
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
                rootPubKey: tvm.pubkey()
            }
        }();
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
