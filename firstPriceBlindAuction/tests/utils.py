# pyright: reportMissingImports=false
import time
import logging
import string
import random
random.seed(0)

import tonos_ts4.ts4 as ts4


owners_bidder = {}

def make_bid(amount_hash, auction_address, value, owner):
    # ts4.init(rootpath.joinpath('contracts/'), verbose = False)
    ts4.Address.ensure_address(auction_address)
    ts4.dispatch_messages()
    bidder = ts4.BaseContract(
        'Bidder',
        dict(
            amountHashX=amount_hash,
            auctionX=auction_address,
        ),
        pubkey='0xaa1787d058eafdf4453274b063e4ddfb05492ddc1b01e91d06681466f35475eb',
        balance=value,
    )
    bidder.call_method('toBid')
    ts4.dispatch_messages()
    owners_bidder[owner] = bidder

def reveal_bid(amount, owner):
    ts4.dispatch_messages()
    bidder = owners_bidder[owner]
    bidder.call_method(
        'toReveal',
        dict(
            amount=amount,
        ),
    )
    ts4.dispatch_messages()

def generate_pubkey():
    return '0x' + ''.join((random.choice(string.hexdigits) for _ in range(64))).lower()
