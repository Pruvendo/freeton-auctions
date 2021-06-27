# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging
import pytest


eq = ts4.eq

LOGGER = logging.getLogger(__name__)

@pytest.mark.order(1)
def test_hello(contract):
    answer = contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)

@pytest.mark.order(2)
def test_deploy_auction(auction_contract):
    answer = auction_contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)
