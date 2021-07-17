/* solhint-disable */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Interfaces.sol";
import "GiverNativeCurrency.sol";

contract Bid is Giver {

    address static public auction;
    address static public lotReciever;

    uint256 static public amountHash;
    uint256 public secret;


    function reveal(
        uint128 amount_,
        uint256 secret_
    ) public {
        require(secret == 0, 103);
        require(tvm.pubkey() == msg.pubkey(), 102);
    
        // require(tvm.checkSign(?????), 201);

        require(address(this).balance >= amount + 2);
        tvm.accept();

        amount = amount_;
        secret = secret_;

        TvmBuilder builder;
        builder.store(
            startTime,
            biddingDuration,
            revealingDuration,
            transferDuration,
            root,
            auction,
            lotReciever,
            amountHash
        );
        TvmCell data = builder.toCell();

        IAuction(auction).revealBid(secret, amount, data);
    }
}
