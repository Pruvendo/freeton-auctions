import tonos_ts4.ts4 as ts4

import logging
import pytest
import time

from utils import (
    make_bid,
    reveal_bid,
    take_bid_back,
    balance,
    prize_balance,
    make_auction_contract,
)


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@pytest.mark.parametrize(
    '''bids, prize, epsilon, start_time,
        bidding_duration, revealing_duration''',
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
            10*10**9,
            2*10**9,
            int(time.time()) + 1000,
            10,
            10,
        ),
    ]
)
def test_scenario(
    root_contract,
    bids,
    prize,
    epsilon,
    start_time,
    bidding_duration,
    revealing_duration
):
    auction_contract = make_auction_contract(
        root_contract=root_contract,
        start_time=start_time,
        bidding_duration=bidding_duration,
        revealing_duration=revealing_duration,
    )
    ts4.core.set_now(start_time + bidding_duration // 2)

    for bid in bids:
        make_bid(
            auction_address=auction_contract.address,
            value=bid['value'],
            owner=bid['owner'],
        )

    assert len(bids) == auction_contract.call_getter('number_of_bids')

    ts4.core.set_now(start_time + bidding_duration + revealing_duration // 2)

    for bid in bids:
        reveal_bid(
            bid['amount'],
            bid['owner'],
        )

    ts4.core.set_now(start_time + bidding_duration + revealing_duration + 1)

    for bid in bids:
        take_bid_back(bid['owner'])

    ts4.dispatch_messages()
    # root_contract.call_method(
    #     'continueAuctionScenario',
    #     dict(
    #         auctionAddress=auction_contract.address,
    #     ),
    #     private_key=root_contract.private_key_,
    # )
    assert auction_contract.bid_reciever.balance <= epsilon
    auction_contract.call_method('end')
    ts4.dispatch_messages()

    for bid in bids:
        assert abs(balance(bid['owner']) -
                   bid['expected_final_balance']) <= epsilon

    for bid in bids:
        if bid['winner']:
            assert abs(auction_contract.bid_reciever.balance -
                       bid['amount']) <= epsilon
            assert abs(prize_balance(bid['owner']) - prize) <= epsilon
        else:
            assert prize_balance(bid['owner']) <= epsilon
