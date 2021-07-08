/* solhint-disable */
pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
// import required DeBot interfaces and basic DeBot contract.
import "../libs/Debot.sol";
import "../libs/Menu.sol";
import "../libs/Terminal.sol";

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
    bytes m_icon;
    address rootContract;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    /// @notice Entry point function for DeBot.
    function start() public override {
        // print string to user.
        Terminal.print(0, "Hello, World!");
        // input string from user and define callback that receives entered string.
        // Terminal.input(tvm.functionId(setUserInput), "How is it going?", false);
        _menu();
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "HelloWorld";
        version = "0.2.0";
        publisher = "TON Labs";
        caption = "Start develop DeBot from here";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94);
        hello = "Hello, i am a HelloWorld DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID ];
    }

    // function setUserInput(string value) public {
    //     // TODO: continue DeBot logic here...
    //     Terminal.print(0, format("You have entered \"{}\"", value));
    // }
    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            "AuctionRootDebot menu",
            sep,
            [
                MenuItem("startAuctionScenario", "",tvm.functionId(startAuctionScenario)),
                MenuItem("continueAuctionScenario", "",tvm.functionId(continueAuctionScenario)),
                MenuItem("getAuctionInfo", "",tvm.functionId(getAuctionInfo))
            ]
        );
    }

    function startAuctionScenario(uint32 index) public {
        Terminal.print(0, "Hack you!1");
        _menu();
    }

    function continueAuctionScenario(uint32 index) public {
        Terminal.print(0, "Hack you!2");
        _menu();
    }

    function getAuctionInfo(uint32 index) public {
        Terminal.print(0, "Hack you!3");
        _menu();
    }
}
