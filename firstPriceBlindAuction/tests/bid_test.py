# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging

from utils import make_bid


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


def test_hello(pytestconfig, auction_contract):
    LOGGER.debug(dir(auction_contract))
    make_bid(0, auction_contract.address, 100500, pytestconfig.rootpath)
    # import time
    # time.sleep(0.5)
    bids = auction_contract.call_getter('bids')
    assert bids
    # answer = contract.call_getter('renderHelloWorld')
    # assert eq('Hello World', answer)
