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
import "../contracts/Interfaces.sol";

struct AuctionScenarioData {
    address lotGiver;
    address bidGiver;
    address lotReciever;
    address bidReciever;

    uint startTime;
    uint biddingDuration;
    uint revealingDuration;
    uint transferDuration;

    bool ended;
}

contract HelloDebot is Debot {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    address root;
    uint256 publicKey;
    mapping(address => AuctionScenarioData) auctions;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                             MENU METHODS                             |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function _menu() private {
        uint64 x = uint64(1 << 64);
        // Terminal.print(0, format("{}", x));
        // string sep = '----------------------------------------';
        string sep = format("{}", x);
        Menu.select(
            sep + "\nAuctionRootDebot menu",
            sep,
            [
                MenuItem("startAuctionScenario", "",tvm.functionId(startAuctionScenario)),
                MenuItem("endAuction", "",tvm.functionId(endAuction)),
                MenuItem("test", "",tvm.functionId(test))
            ]
        );
    }

    function startAuctionScenario(uint32 index) public {
        AddressInput.get(
            tvm.functionId(__saveLotGiver),
            "Enter the lot giver address:"
        );
    }

    function startAuctionScenario_(
        address auction
    ) public {
        Terminal.print(0, "Some usefull info coming...");
        address none;
        auctions[auction] = AuctionScenarioData({
            lotGiver: __lotGiver,
            bidGiver: none,
            lotReciever: none,
            bidReciever: __bidReciever,

            startTime: __startTime,
            biddingDuration: __biddingDuration,
            revealingDuration: __revealingDuration,
            transferDuration: __transferDuration,

            ended: false
        });
        _menu();
    }

    function endAuction(uint32 index) public {
        AddressInput.get(
            tvm.functionId(endAuction_),
            "Auction to end (address):"
        );
    }

    function endAuction_(address value) public {
        IAuction(value).end();
        _menu();
    }

    function test(uint32 index) public {
        Terminal.print(0, "Hello World!");
        _menu();
    }

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                              READING                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

    // on startup
    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            publicKey = res;
        } else {
            Terminal.inputStr(
                tvm.functionId(savePublicKey),
                "Wrong public key. Try again!\nPlease enter your public key",
                false
            );
        }
    }

    function saveRootAddress(address value) public {
        root = value;
    }

    // to start auction scenario
    address __bidReciever;
    address __lotGiver;
    uint __startTime;
    uint __biddingDuration;
    uint __revealingDuration;
    uint __transferDuration;

    function __saveLotGiver(address value) public {
        __lotGiver = value;
        AddressInput.get(
            tvm.functionId(__saveBidReciever),
            "Bid reciever's address:"
        );
    }

    function __saveBidReciever(address value) public {
        __bidReciever = value;
        Terminal.inputUint(
            tvm.functionId(__saveStartTime),
            "Enter auction's start time (epoche time):"
        );
    }

    function __saveStartTime(uint256 value) public {
        __startTime = uint(value);
        Terminal.inputUint(
            tvm.functionId(__saveBiddingDuration),
            "Enter auction's bidding stage's duration (seconds):"
        );
    }

    function __saveBiddingDuration(uint256 value) public {
        __biddingDuration = uint(value);
        Terminal.inputUint(
            tvm.functionId(__saveRevealingDuration),
            "Enter auction's revealing stage's duration (seconds):"
        );
    }

    function __saveRevealingDuration(uint256 value) public {
        __revealingDuration = uint(value);
        Terminal.inputUint(
            tvm.functionId(__saveTransferDuration),
            "Enter auction's final transfer stage's duration (seconds):"
        );
    }

    function __saveTransferDuration(uint256 value) public {
        __transferDuration = uint(value);
        IRoot(root).startAuctionScenario{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: publicKey,
            time: uint64(now),
            expire: now + 100,
            callbackId: tvm.functionId(startAuctionScenario_),
            onErrorId: tvm.functionId(onError)
        }({
            lotGiver: __lotGiver,
            bidReciever: __bidReciever,
            startTime: __startTime,
            biddingDuration: __biddingDuration,
            revealingDuration: __revealingDuration,
            transferDuration: __transferDuration
        });
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
        name = "AuctionRootDebot";
        version = "0.0.1";
        publisher = "Pruvendo";
        caption = "Start develop DeBot from here";
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

    function start() public override {
        Terminal.inputStr(tvm.functionId(savePublicKey), "Enter your public key:", false);
        AddressInput.get(tvm.functionId(saveRootAddress),"Enter root contract's address:");
        _menu();
    }
}
