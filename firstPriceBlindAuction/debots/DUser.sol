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


contract AuctionUserDebot is Debot {

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                                DATA                                  |
    |                                                                      |
    \---------------------------------------------------------------------*/

    

    /*---------------------------------------------------------------------\
    |                                                                      |
    |                             MENU METHODS                             |
    |                                                                      |
    \---------------------------------------------------------------------*/

    function start() public override {
        Terminal.inputStr(tvm.functionId(savePublicKey), "Enter your public key:", false);
        AddressInput.get(tvm.functionId(saveAuctionAddress),"Enter root auctions's address:");
        _menu();
    }

    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            sep + "\nAuctionUserDebot menu",
            sep,
            [
                MenuItem("makeBid", "",tvm.functionId()),
                MenuItem("revealBid", "",tvm.functionId()),
                MenuItem("takeBidBack", "",tvm.functionId()),
                MenuItem("test", "",tvm.functionId(test))
            ]
        );
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

    function saveAuctionAddress(address value) public {
        auction = value;
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

    function start() public override {
        Terminal.inputStr(tvm.functionId(savePublicKey), "Enter your public key:", false);
        AddressInput.get(tvm.functionId(saveRootAddress),"Enter root contract's address:");
        _menu();
    }
}
