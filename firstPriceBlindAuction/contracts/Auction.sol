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
    address static public root;

    mapping(address => BidData) public bids;
    BidData public winner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.sender == root, 102);
    }

    function makeBid(
        uint256 amountHash,
        address prizeReciever
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
        require(signature.length == 64, 103);
        require(bids.exists(msg.sender), 102);
        require(
            (now < (startTime + biddingDuration + revealingDuration))
                && (now >= (startTime + biddingDuration)),
            103
        );
        // require(bidData.pubkey == msg.pubkey(), 104);
        // require(tvm.checkSign(
        //         bidData.amountHash,
        //         signature.toSlice(),
        //         bidData.pubkey
        //     ), 201);

        // TODO: require hash value is correct

        bids[msg.sender].amount = amount;
        bids[msg.sender].amountSecret = signature;

        if (winner.bid.isNone()) {
            BidInterface(bids[msg.sender].bid).unfreeze(amount);
            winner = bids[msg.sender];
        } else {
            if (winner.amount < bids[msg.sender].amount) {
                BidInterface(winner.bid).unfreeze(0);
                BidInterface(bids[msg.sender].bid).unfreeze(amount);
                winner = bids[msg.sender];
            }
        }
    }

    function endAuction() override public returns (address) {
        require(msg.sender == root, 102);
        require(now >= (startTime + biddingDuration + revealingDuration), 103);
        
        RootInterface(msg.sender).setWinner(winner.bid, winner.prizeReciever);
    }

    function takeBidBack(address destination) override external {
        require(bids.exists(msg.sender), 102);
        BidData bidData = bids[msg.sender];
        require(!winner.bid.isNone(), 101);
        require(!bidData.amountSecret.empty(), 101);
        require(now >= (startTime + biddingDuration + revealingDuration), 103);

        tvm.accept();
        BidInterface(bidData.bid).transferRemainsTo(destination);
    }
}
