# pyright: reportMissingImports=false
import pathlib
import time
import logging
import random

import tonos_ts4.ts4 as ts4

from pytest import fixture

from utils import generate_pubkey, dumb_reciever


LOGGER = logging.getLogger(__name__)


@fixture(scope='session')
def fix_path(pytestconfig):
    rootpath: pathlib.Path = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose = False)

@fixture(scope='session')
def root_contract():
    auction_code = ts4.load_code_cell('Auction.tvc')
    giver_code = ts4.load_code_cell('Giver.tvc')
    bid_code = ts4.load_code_cell('Bid.tvc')
    return ts4.BaseContract(
        'AuctionRoot',
        dict(
            auctionCodeArg=auction_code,
            giverCodeArg=giver_code,
            bidCodeArg=bid_code,
            rootIdArg=random.randint(1, 10000)
        ),
        balance=30 * 10 ** 9,
        nickname = 'Root'
    )

@fixture(scope='session')
def auction_contract(root_contract):
    reciever = dumb_reciever()
    auction_address = root_contract.call_method('startAuctionScenario', dict(
        prize=100500,
        bidReciever=reciever.address,
        startTime=int(time.time()) + 10,
        biddingDuration=1,
        revealingDuration=1,
        publicKey=generate_pubkey(),
    ))

    ts4.Address.ensure_address(auction_address)
    ts4.register_nickname(auction_address, 'Auction')
    ts4.dispatch_messages()
    res = ts4.BaseContract(
        'Auction',
        ctor_params=None,
        address=auction_address,
        nickname='AuctionInstance'
    )
    ts4.dispatch_messages()
    res.bid_reciever = reciever
    return res

