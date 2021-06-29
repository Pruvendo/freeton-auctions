# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import logging

import pytest

from time import sleep

from utils import make_bid, reveal_bid, take_bid_back, balance


eq = ts4.eq

LOGGER = logging.getLogger(__name__)

@pytest.mark.order(3)
def test_scenario(auction_contract, root_contract):
    make_bid('0', auction_contract.address, 10**11, 'Vasya')
    make_bid('0', auction_contract.address, 2 * 10**11, 'Petya')
    assert 2 == auction_contract.call_getter('number_of_bids')
    
    reveal_bid(10**10, 'Petya')
    winner = auction_contract.call_getter('winner')
    assert winner['amount'] == 10**10
    assert winner['amount'] < winner['value']

    reveal_bid(2 * 10**10, 'Vasya')
    winner = auction_contract.call_getter('winner')
    assert winner['amount'] == 2 * 10**10
    assert winner['amount'] < winner['value']

    ts4.dispatch_messages()
    root_contract.call_method(
        'continueAuctionScenario',
        dict(
            auctionAddress=auction_contract.address,
        )
    )
    ts4.dispatch_messages()
    winner = auction_contract.call_getter('winner')
    auctions = root_contract.call_getter('auctions')
    assert len(auctions) == 1
    assert list(auctions.values())[0]['ended'] == True
    assert list(auctions.values())[0]['winnerBid'] == winner['bid']
    
    LOGGER.debug(winner)
    take_bid_back('Petya')
    take_bid_back('Vasya')
    LOGGER.debug(balance('Petya'))
    assert abs(2 * 10**11 - balance('Petya')) < 2 * 10**9
    assert abs((10**11 - 2 * 10**10) - balance('Vasya')) < 2 * 10**9
