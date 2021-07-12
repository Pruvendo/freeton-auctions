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

interface IAuctionRoot {
    function startAuctionScenario(
        uint prize, // nope
        address bidReciever,
        uint startTime,
        uint biddingDuration,
        uint revealingDuration,
        uint256 publicKey
    ) external returns (address auctionAddress);
    function continueAuctionScenario(address auctionAddress) external;
    function getInfo() external returns (string);
}

contract HelloDebot is Debot {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    bytes m_icon;
    address root;
    address[] auctions;
    uint256 publicKey;

    bool __got_x;
    uint128 __x;

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                              METHODS                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function start() public override {
        __got_x = false;
        Terminal.input(tvm.functionId(savePublicKey), "Enter your public key:", false);
        AddressInput.get(tvm.functionId(saveRootAddress),"Enter root contract's address:");
        _menu();
    }

    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            sep + "\nAuctionRootDebot menu",
            sep,
            [
                MenuItem("startAuctionScenario", "",tvm.functionId(startAuctionScenario)),
                MenuItem("continueAuctionScenario", "",tvm.functionId(continueAuctionScenario)),
                MenuItem("getRootInfo", "",tvm.functionId(getRootInfo)),
                MenuItem("test", "",tvm.functionId(test))
            ]
        );
    }

    function startAuctionScenario(uint32 index) public {
        address n;
        IAuctionRoot(root).startAuctionScenario{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: publicKey,
            time: uint64(now),
            expire: now + 100,
            callbackId: tvm.functionId(startAuctionScenario_),
            onErrorId: tvm.functionId(onError)
        }(
            100500,
            n,
            now + 1000,
            10,
            10,
            publicKey
        );
    }

    function startAuctionScenario_(address auction_) public {
        Terminal.print(0, format("\nNew auction's address: {}", auction_));
        auctions.push(auction_);
        _menu();
    }

    function continueAuctionScenario(uint32 index) public {
        Terminal.print(0, "Hack you!2");
        _menu();
    }

    function continueAuctionScenario_(uint32 index) public {
        Terminal.print(0, "Hack you!2");
        _menu();
    }

    function getRootInfo(uint32 index) public {
        optional(uint256) none;
        IAuctionRoot(root).getInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: now + 100,
            callbackId: tvm.functionId(getRootInfo_),
            onErrorId: tvm.functionId(onError)
        }();
    }

    function getRootInfo_(string info) public {
        Terminal.print(0, info);
        _menu();
    }

    function test(uint32 index) public {
        Terminal.print(0, format("Hello World!"));
        _menu();
    }

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                        READING CHAINS                                |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            publicKey = res;
        } else {
            Terminal.input(
                tvm.functionId(savePublicKey),
                "Wrong public key. Try again!\nPlease enter your public key",
                false
            );
        }
    }

    function saveRootAddress(address value) public {
        root = value;
    }

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                            TECHNICAL                                 |
    |                                                                      |
    \---------------------------------------------------------------------*/

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
}
