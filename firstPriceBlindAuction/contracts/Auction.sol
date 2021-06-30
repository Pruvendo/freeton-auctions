/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Bid.sol";
import "Interfaces.sol";

struct BidData {
    address bid;
    address prizeReciever;
    uint128 value;
    uint128 amount;
    uint256 amountHash;
    bytes amountSecret;
}

contract Auction is AucInterface {

    uint public number_of_bids;
    uint static public a_id;
    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    TvmCell static public bidCode;
    // uint256 static public rootPubKey;
    address static public root;

    mapping(address => BidData) public bids;
    BidData public winner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root, 102);

        tvm.accept();
    }

    function makeBid(
        uint256 amountHash,
        address prizeReciever
    ) override external returns (address bid) {
        require(msg.value >= 3 ton, 103);
        tvm.accept();

        bid = new Bid{
            code: bidCode,
            value: msg.value,
            pubkey: tvm.pubkey(),
            varInit: {
                root: root,
                auction: this,
                prizeReciever: prizeReciever,
                b_id: number_of_bids
            }
        }();
        number_of_bids = number_of_bids + 1;

        bids[msg.sender] = BidData(
            bid,
            prizeReciever,
            msg.value,
            0,
            amountHash,
            ""
        );
    }

    function revealBid(bytes signature, uint128 amount) override external {
        require(signature.length == 64, 200);
        require(bids.exists(msg.sender), 103);
        BidData bidData = bids[msg.sender];
        // require(bidData.pubkey == msg.pubkey(), 104);
        // require(tvm.checkSign(
        //         bidData.amountHash,
        //         signature.toSlice(),
        //         bidData.pubkey
        //     ), 201);

        // TODO: require hash value is correct

        bidData.amount = amount;
        bidData.amountSecret = signature;

        if (winner.bid.isNone()) {
            BidInterface(bidData.bid).unfreeze(amount);
            winner = bidData;
        } else {
            if (winner.amount < bidData.amount) {
                BidInterface(winner.bid).unfreeze(0);
                BidInterface(bidData.bid).unfreeze(amount);
                winner = bidData;
            }
        }
    }

    function endAuction() override public returns (address) {
        require(msg.sender == root, 102);
        
        RootInterface(msg.sender).setWinner(winner.bid, winner.prizeReciever);
    }

    function takeBidBack(address destination) override external {
        require(bids.exists(msg.sender), 101);
        BidData bidData = bids[msg.sender];
        require(!winner.bid.isNone(), 102);
        // require(bidData.pubkey == msg.pubkey(), 104);

        tvm.accept();
        BidInterface(bidData.bid).transferRemainsTo(destination);
        // require(false, 322);
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }
}
