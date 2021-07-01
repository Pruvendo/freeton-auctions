/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Bid.sol";
import "Interfaces.sol";

struct BidData {
    address bid;
    address lotReciever;
    uint128 value;
    uint128 amount;
    uint256 amountHash;
    bytes secret;
}

contract Auction is IAuction {

    uint public number_of_bids;
    uint static public a_id;
    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    TvmCell static public bidCode;
    address static public root;

    mapping(address => BidData) public bids;
    BidData public winner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root, 102);
    }

    function makeBid(
        uint256 amountHash,
        address lotReciever
    ) override external returns (address bid) {
        require(msg.value >= 3 ton, 103);
        require(
            now < (startTime + biddingDuration) && now >= startTime,
            103
        );
        tvm.accept();

        bid = new Bid{
            code: bidCode,
            value: msg.value,
            pubkey: tvm.pubkey(),
            varInit: {
                root: root,
                auction: this,
                lotReciever: lotReciever,
                b_id: number_of_bids
            }
        }();
        number_of_bids = number_of_bids + 1;

        bids[msg.sender] = BidData(
            bid,
            lotReciever,
            msg.value,
            0,
            amountHash,
            ""
        );
    }

    function revealBid(bytes signature, uint128 amount) override external {
        require(signature.length == 64, 103);
        require(bids.exists(msg.sender), 102);
        require(
            (now < (startTime + biddingDuration + revealingDuration))
                && (now >= (startTime + biddingDuration)),
            103
        );

        // require(tvm.checkSign(?????), 201);

        bids[msg.sender].amount = amount;
        bids[msg.sender].secret = signature;

        if (winner.bid.isNone()) {
            IBid(bids[msg.sender].bid).unfreeze(amount);
            winner = bids[msg.sender];
        } else {
            if (winner.amount < bids[msg.sender].amount) {
                IBid(winner.bid).unfreeze(0);
                IBid(bids[msg.sender].bid).unfreeze(amount);
                winner = bids[msg.sender];
            }
        }
    }

    function endAuction() override public {
        require(msg.sender == root, 102);
        require(now >= (startTime + biddingDuration + revealingDuration), 103);
        
        IRoot(msg.sender).setWinner(winner.bid, winner.lotReciever);
    }

    function takeBidBack(address destination) override external {
        require(bids.exists(msg.sender), 102);
        BidData bidData = bids[msg.sender];
        require(!winner.bid.isNone(), 101);
        require(!bidData.secret.empty(), 101);
        require(now >= (startTime + biddingDuration + revealingDuration), 103);

        tvm.accept();
        IBid(bidData.bid).transferRemainsTo(destination);
    }
}
