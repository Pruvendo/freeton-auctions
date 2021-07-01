import logging
import random

import tonos_ts4.ts4 as ts4


LOGGER = logging.getLogger(__name__)
owners_bidder: dict[str, (ts4.BaseContract, (str, str))] = {}


def dumb_reciever():
    return ts4.BaseContract(
        'DumbReciever',
        dict(
            idArg=random.randint(0, 100000),
        ),
        balance=10**9,
    )


def make_bid(auction_address, value, owner, expect_ec=0, amount_hash='0'):
    ts4.Address.ensure_address(auction_address)
    reciever = dumb_reciever()
    ts4.dispatch_messages()
    keypair = ts4.make_keypair()
    bidder = ts4.BaseContract(
        'Bidder',
        dict(
            amountHashArg=amount_hash,
            auctionArg=auction_address,
            recieverArg=reciever.address,
        ),
        keypair=keypair,
        balance=value,
    )
    bidder.call_method(
        'toBid',
        expect_ec=expect_ec,
        private_key=keypair[0],
    )
    bidder.prize_reciever = reciever
    ts4.dispatch_messages()
    owners_bidder[owner] = (bidder, keypair)


def reveal_bid(amount, owner, expect_ec=0):
    ts4.dispatch_messages()
    bidder = owners_bidder[owner][0]
    bidder.call_method(
        'toReveal',
        dict(
            amount=amount,
        ),
        expect_ec=expect_ec
    )
    ts4.dispatch_messages()


def take_bid_back(owner, expect_ec=0):
    ts4.dispatch_messages()
    bidder = owners_bidder[owner][0]
    bidder.call_method('takeBidBack')
    ts4.dispatch_one_message(expect_ec=expect_ec)


def balance(owner):
    bidder = owners_bidder[owner][0]
    ts4.dispatch_messages()
    return bidder.balance


def prize_balance(owner):
    bidder = owners_bidder[owner][0]
    ts4.dispatch_messages()
    return bidder.prize_reciever.balance


def make_auction_contract(
    root_contract,
    start_time,
    bidding_duration,
    revealing_duration,
):
    reciever = dumb_reciever()
    ts4.dispatch_messages()
    auction_address = root_contract.call_method(
        'startAuctionScenario',
        dict(
            prize=100500,
            bidReciever=reciever.address,
            startTime=start_time,
            biddingDuration=bidding_duration,
            revealingDuration=revealing_duration,
            publicKey=ts4.make_keypair()[1],
        ),
        private_key=root_contract.private_key_,
    )

    ts4.Address.ensure_address(auction_address)
    ts4.dispatch_messages()
    res = ts4.BaseContract(
        'Auction',
        ctor_params=None,
        address=auction_address,
    )
    ts4.dispatch_messages()
    res.bid_reciever = reciever
    return res
