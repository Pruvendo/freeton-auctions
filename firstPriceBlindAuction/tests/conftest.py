import pathlib
import logging

import tonos_ts4.ts4 as ts4

from pytest import fixture


LOGGER = logging.getLogger(__name__)


@fixture(scope='session')
def fix_path(pytestconfig):
    rootpath: pathlib.Path = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose=False)


@fixture(scope='session')
def root_contract():
    auction_code = ts4.load_code_cell('Auction')
    giver_code = ts4.load_code_cell('GiverNativeCurrency')
    bid_code = ts4.load_code_cell('BidNativeCurrencyFirstPrice')
    return ts4.BaseContract(
        'AuctionRoot',
        dict(
            auctionCode_=auction_code,
            lotGiverCode_=giver_code,
            bidGiverCode_=bid_code,
        ),
        balance=10 ** 12,
        keypair=ts4.make_keypair(),
    )
