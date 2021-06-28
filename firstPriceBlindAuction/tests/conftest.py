# pyright: reportMissingImports=false
import pathlib
import time
import logging
import random
random.seed(0)

import tonos_ts4.ts4 as ts4

from pytest import fixture

# from constants import ROOT_PUB_KEY
from utils import generate_pubkey


LOGGER = logging.getLogger(__name__)


@fixture(scope='session')
def fix_path(pytestconfig):
    rootpath: pathlib.Path = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose = False)


@fixture(scope="session")
def root_contract():
    # rootpath: pathlib.Path = pytestconfig.rootpath
    # ts4.init(rootpath.joinpath('contracts/'), verbose = False)
    auction_code = ts4.load_code_cell('Auction.tvc')
    giver_code = ts4.load_code_cell('Giver.tvc')
    bid_code = ts4.load_code_cell('Bid.tvc')
    return ts4.BaseContract(
        'AuctionRoot',
        dict(
            auctionCodeArg=auction_code,
            giverCodeArg=giver_code,
            bidCodeArg=bid_code,
            rootIdArg=random.randint(0, 1000000)
        ),
        pubkey=generate_pubkey(),
        balance=100000000000,
        nickname = 'Root'
    )

@fixture(scope="session")
def auction_contract(root_contract):
    # LOGGER.debug(dir(contract))
    auction_address = root_contract.call_method('startAuctionScenario', dict(
        prize=100500,
        startTime=int(time.time()) + 10,
        biddingDuration=1,
        revealingDuration=1,
        publicKey=generate_pubkey(),
    ))
    # LOGGER.debug(auctions[i])

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
    return res

@fixture(scope='session')
def bid(auction_contract):
    bid_address = auction_contract.call_method(
        'makeBid',
        dict(
            amountHash=0,
        ),
    )

    ts4.Address.ensure_address(bid_address)
    ts4.register_nickname(bid_address, 'Bid')
    ts4.dispatch_messages()
    return ts4.BaseContract(
        'Bid',
        ctor_params=None,
        address=bid_address,
        # nickname='BidInstance'
    )
