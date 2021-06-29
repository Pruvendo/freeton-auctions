# pyright: reportMissingImports=false
import time
import logging
import string
import random
random.seed(3)

import tonos_ts4.ts4 as ts4


LOGGER = logging.getLogger(__name__)
owners_bidder: dict[str, ts4.BaseContract] = {}

def make_bid(amount_hash, auction_address, value, owner, expect_ec=0):
    # ts4.init(rootpath.joinpath('contracts/'), verbose = False)
    ts4.Address.ensure_address(auction_address)
    ts4.dispatch_messages()
    bidder = ts4.BaseContract(
        'Bidder',
        dict(
            amountHashX=amount_hash,
            auctionX=auction_address,
        ),
        pubkey=generate_pubkey(),
        balance=value,
    )
    bidder.call_method('toBid', expect_ec=expect_ec)
    ts4.dispatch_messages()
    owners_bidder[owner] = bidder

def reveal_bid(amount, owner, expect_ec=0):
    ts4.dispatch_messages()
    bidder = owners_bidder[owner]
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
    bidder = owners_bidder[owner]
    LOGGER.debug(bidder.public_key_)
    bidder.call_method('takeBidBack')
    ts4.dispatch_one_message(expect_ec=expect_ec)

def balance(owner):
    bidder = owners_bidder[owner]
    ts4.dispatch_messages()
    return bidder.balance

def generate_pubkey():
    return '0xaa' + ''.join((random.choice(string.hexdigits) for _ in range(62))).lower()
