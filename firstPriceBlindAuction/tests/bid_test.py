# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging

import pytest

from utils import make_bid


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@pytest.mark.order(4)
def test_hello(bid):
    answer = bid.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)

@pytest.mark.order(5)
def test_hello1(bid):
    pass
