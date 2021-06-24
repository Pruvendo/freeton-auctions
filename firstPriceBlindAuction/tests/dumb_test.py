# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


def test_hello(contract):
    answer = contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)

def test_deploy_auction(auction_contract):
    answer = auction_contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)
