/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Bid.sol";
import "Interfaces.sol";

struct BidData {
    address bid;
    uint256 value;
    uint256 amount;
    uint256 amountHash;
    bytes amountSecret;
    uint256 pubkey;
}

contract Auction is AucInterface {

    uint public number_of_bids;
    uint static public a_id;
    uint static public startTime;
    uint static public biddingDuration;
    uint static public revealingDuration;
    TvmCell static public bidCode;
    uint256 static public rootPubKey;

    mapping(address => BidData) public bids;
    BidData public winner;

    // constructor() public {
    //     // require(tvm.pubkey() != 0, 101);
    //     // require(msg.pubkey() == tvm.pubkey(), 102);

    //     // require(0 != 0, 111);

    //     tvm.accept();
    // }

    function makeBid(uint256 amountHash) override external returns (address bid) {
        // require...
        // require(1 == 2, 102);
        tvm.accept();

        bid = new Bid{
            code: bidCode,
            value: msg.value,
            pubkey: tvm.pubkey(),
            varInit: {
                rootPubKey: rootPubKey,
                b_id: number_of_bids
            }
        }();
        number_of_bids = number_of_bids + 1;

        bids[msg.sender] = BidData(
            bid,
            msg.value,
            0,
            amountHash,
            "",
            msg.pubkey()
        );
    }

    function revealBid(bytes signature, uint amount) override external {
        require(signature.length == 64, 200);
        require(bids.exists(msg.sender), 102);
        BidData bidData = bids[msg.sender];
        require(bidData.pubkey == msg.pubkey(), 102);
        // require(tvm.checkSign(
        //         bidData.amountHash,
        //         signature.toSlice(),
        //         bidData.pubkey
        //     ), 201);

        // TODO: require hash value is correct

        bidData.amount = amount;
        bidData.amountSecret = signature;

        if (winner.bid.isNone()) {
            winner = bidData;
        } else {
            if (winner.amount < bidData.amount) {
                winner = bidData;
            }
        }
    }

    function endAuction() override public returns (address) {
        //require...
        
        RootInterface(msg.sender).setWinner(winner.bid);
    }

    function takeBidBack(address destination) public {
        require(bids.exists(msg.sender), 102);
        BidData bidData = bids[msg.sender];
        require(!winner.bid.isNone(), 102);
        require(winner.pubkey != msg.pubkey(), 102);
        require(bidData.pubkey == msg.pubkey(), 102);

        tvm.accept();
        BidInterface(bidData.bid).transferTo(destination);
    }

    function renderHelloWorld() public pure returns (string) {
        return "Hello World";
    }

    receive() external pure {}
}
