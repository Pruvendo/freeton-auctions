# pyright: reportMissingImports=false
import time
import logging
import string
import random
random.seed(3)

import tonos_ts4.ts4 as ts4


LOGGER = logging.getLogger(__name__)
owners_bidder: dict[str, ts4.BaseContract] = {}

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
    bidder = ts4.BaseContract(
        'Bidder',
        dict(
            amountHashArg=amount_hash,
            auctionArg=auction_address,
            recieverArg=reciever.address,
        ),
        pubkey=generate_pubkey(),
        balance=value,
    )
    bidder.call_method('toBid', expect_ec=expect_ec)
    bidder.prize_reciever = reciever
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
    bidder.call_method('takeBidBack')
    ts4.dispatch_one_message(expect_ec=expect_ec)

def balance(owner):
    bidder = owners_bidder[owner]
    ts4.dispatch_messages()
    return bidder.balance

def prize_balance(owner):
    bidder = owners_bidder[owner]
    ts4.dispatch_messages()
    return bidder.prize_reciever.balance

def generate_pubkey():
    return '0xaa' + ''.join((random.choice(string.hexdigits) for _ in range(62))).lower()
