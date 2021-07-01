import tonos_ts4.ts4 as ts4

import logging

import pytest

from time import sleep

from utils import (
    make_bid,
    reveal_bid,
    take_bid_back,
    balance,
    prize_balance
)


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@pytest.mark.parametrize(
    "bids, prize, epsilon",
    [
        (
            [
                {
                    'owner': 'Petya',
                    'value': 2*10**11,
                    'amount': 10**10,
                    'winner': False,
                    'expected_final_balance': 2*10**11,
                },
                {
                    'owner': 'Vasya',
                    'value': 10**11,
                    'amount': 2*10**10,
                    'winner': True,
                    'expected_final_balance': 10**11 - 2*10**10,
                },
            ],
            10 * 10 ** 9,
            2 * 10 ** 9,
        ),
    ]
)
@pytest.mark.order(3)
def test_scenario(auction_contract, root_contract, bids, prize, epsilon):
    for bid in bids:
        make_bid(
            auction_address=auction_contract.address,
            value=bid['value'],
            owner=bid['owner'],
        )

    assert len(bids) == auction_contract.call_getter('number_of_bids')

    for bid in bids:
        reveal_bid(
            bid['amount'],
            bid['owner'],
        )
    
    for bid in bids:
        take_bid_back(bid['owner'])

    ts4.dispatch_messages()
    root_contract.call_method(
        'continueAuctionScenario',
        dict(
            auctionAddress=auction_contract.address,
        ),
        private_key=root_contract.private_key_,
    )
    ts4.dispatch_messages()

    for bid in bids:
        assert abs(balance(bid['owner']) - bid['expected_final_balance']) <= epsilon
    
    for bid in bids:
        if bid['winner']:
            assert abs(auction_contract.bid_reciever.balance - bid['amount']) <= epsilon
            assert abs(prize_balance(bid['owner']) - prize) <= epsilon
        else:
            assert prize_balance(bid['owner']) <= epsilon
