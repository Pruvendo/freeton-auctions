/* solhint-disable */
pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// import required DeBot interfaces and basic DeBot contract.
import "../libs/Debot.sol";
import "../libs/Menu.sol";
import "../libs/Terminal.sol";
import "../libs/AddressInput.sol";
import "../libs/AmountInput.sol";
import "../libs/Sdk.sol";
import "../contracts/Interfaces.sol";


contract AuctionUserDebot is Debot {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    // mapping(address => BidData) bids;
    TvmCell bidGiverCode;
    address wallet;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                             MENU METHODS                             |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function start() public override {
        _menu();
    }

    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            sep + "\nAuctionUserDebot menu",
            sep,
            [
                MenuItem("getAuctionInfo", "",tvm.functionId(getAuctionInfo)),
                MenuItem("makeBid", "",tvm.functionId(makeBid)),
                MenuItem("revealBid", "",tvm.functionId(revealBid)),
                MenuItem("takeBidBack", "",tvm.functionId(takeBidBack))
            ]
        );
    }

    function getAuctionInfo(uint32 index) public {
        AddressInput.get(
            tvm.functionId(__callGetAuctionInfoBeforePrint),
            "Auctions's address:"
        );
    }

    function makeBid(uint32 index) public {
        AddressInput.get(
            tvm.functionId(__callGetAuctionInfoBeforeBid),
            "Auctions's address:"
        );
    }

    function revealBid(uint32 index) public {
        
    }

    function takeBidBack(uint32 index) public {
        
    }

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                              READING                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function __callGetAuctionInfoBeforePrint(address addr) public {
        optional(uint256) none;
        IAuction(addr).getAllInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: 0,
            expire: 0,
            callbackId: tvm.functionId(__printAuctionInfo),
            onErrorId: tvm.functionId(onError)
        }();
    }

    function __printAuctionInfo(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint transferDuration,

        address lotGiver,
        address bidReciever,

        address bidGiver,
        address lotReciever,
        uint128 amount,

        address root,
        bool ended
    ) public {
        Terminal.print(0, format("  Auction's address: {}", msg.sender));
        Terminal.print(0, format("    Auction's lotGiver: {}", lotGiver));
        Terminal.print(0, format("    Auction's bidReciever: {}", bidReciever));
        Terminal.print(0, format("    Auction's winner.bidGiver: {}", bidGiver));
        Terminal.print(0, format("    Auction's winner.lotReciever: {}", lotReciever));
        Terminal.print(0, format("    Auction's winner.amount: {}", amount));
        Terminal.print(0, format("    Auction's startTime: {}", startTime));
        Terminal.print(0, format("    Auction's biddingDuration: {}", biddingDuration));
        Terminal.print(0, format("    Auction's revealingDuration: {}", revealingDuration));
        Terminal.print(0, format("    Auction's transferDuration: {}", transferDuration));
        Terminal.print(0, format("    Auction ended: {}", ended ? "yes" : "no"));
        _menu();
    }

    // make bid
    uint __startTime;
    uint __biddingDuration;
    uint __revealingDuration;
    uint __transferDuration;

    address __root;
    address __auction;
    address __lotReciever;

    uint128 __amount;
    uint256 __amountHash;
    string __secret;

    uint256 __ownerPubkey;

    function __callGetAuctionInfoBeforeBid(address addr) public {
        __auction = addr;
        optional(uint256) none;
        IAuction(__auction).getAllInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: 0,
            expire: 0,
            callbackId: tvm.functionId(__setAucInfo),
            onErrorId: tvm.functionId(onError)
        }();
    }

    function __setAucInfo(
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint transferDuration,

        address lotGiver,
        address bidReciever,

        address bidGiver,
        address lotReciever,
        uint128 amount,

        address root,
        bool ended
    ) public {
        __startTime = startTime;
        __biddingDuration = biddingDuration;
        __revealingDuration = revealingDuration;
        __transferDuration = transferDuration;
        __root = root;

        Terminal.inputUint(tvm.functionId(saveAmount), "How much nanotons do you wanna bid:");
    }

    function saveAmount(uint128 amount) public {
        __amount = amount;
        AddressInput.get(
            tvm.functionId(__saveLotReciever),
            "Enter lot reciever's address:"
        );
    }

    function __saveLotReciever(address addr) public {
        __lotReciever = addr;
        Sdk.mnemonicFromRandom(tvm.functionId(setMnemonic), 1, 12);
    }

    function setMnemonic(string phrase) public {
        __secret = phrase;
        TvmBuilder builder;
        builder.store(
            phrase,
            "Let me take you down, cos I'm going to Strawberry Fields Nothing is real and nothing to get hung about Strawberry Fields forever",
            __amount
        );
        __amountHash = tvm.hash(builder.toCell());

        Terminal.print(0, "Now you're ready to deploy your bid.");
        
        builder.store(
            __startTime,
            __biddingDuration,
            __revealingDuration,
            __transferDuration,
            __root,
            __auction,
            __lotReciever,
            __amountHash
        );
        TvmCell stateInit = tvm.buildStateInit(bidGiverCode, builder.toCell());
        TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, __ownerPubkey);
        address addr = address(tvm.hash(stateInitWithKey));

        Terminal.print(0, format("1. Please, transfer at least {} nanoton to {} with your wallet.", __amount + 3 ton, addr));
        Terminal.print(0, format(
                "2. Deploy it in this way:"
                "tonos-cli --url $NETWORK \""
                "deploy Bid.tvc \""
                "--sign keyfile.json \""
                "--abi Bid.abi.json \""
                "\"{"
                    "    \"startTime\": {},"
                    "    \"biddingDuration\": {},"
                    "    \"revealingDuration\": {},"
                    "    \"transferDuration\": {},"
                    "    \"root\": {},"
                    "    \"auction\": {},"
                    "    \"lotReciever\": {},"
                    "    \"amountHash\": {},"
                "}\";",
                __startTime, __biddingDuration, __revealingDuration, __transferDuration,
                __root, __auction, __lotReciever, __amountHash
            )
        );
    }

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                            TECHNICAL                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/
    
    bytes m_icon;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "AuctionUserDebot";
        version = "0.0.1";
        publisher = "Pruvendo";
        caption = "lorem ipsum";
        author = "Pruvendo";
        language = "en";
        dabi = m_debotAbi.get();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID ];
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Oooops!\nsdkError: {}, exitCode: {}", sdkError, exitCode));
        _menu();
    }
}
