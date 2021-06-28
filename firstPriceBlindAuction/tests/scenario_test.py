# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging

import pytest

from time import sleep

from utils import make_bid


eq = ts4.eq

LOGGER = logging.getLogger(__name__)

@pytest.mark.order(3)
def test_scenario(auction_contract, pytestconfig):
    pass
    answer = auction_contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)
    make_bid('0', auction_contract.address, 10**9, pytestconfig.rootpath)
    make_bid('0', auction_contract.address, 2 * 10**9, pytestconfig.rootpath)
    assert 2 == auction_contract.call_getter('number_of_bids')
    # sleep(1)
