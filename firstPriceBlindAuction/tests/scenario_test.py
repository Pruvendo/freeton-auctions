import tonos_ts4.ts4 as ts4

import logging
import pytest
import time

from utils import (
    dumb_reciever,
    make_bid,
    reveal_bid,
    take_bid_back,
    balance,
    prize_balance,
    make_auction_contract,
    make_lot_giver,
)


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@pytest.mark.parametrize(
    '''bids, prize, epsilon, start_time,
        bidding_duration, revealing_duration, transfer_duration''',
    [
        (
            [
                {
                    'username': 'Petya',
                    'value': 2*10**11,
                    'amount': 10**10,
                    'winner': False,
                    'expected_final_balance': 2*10**11,
                    'secret': 123,
                },
                {
                    'username': 'Vasya',
                    'value': 10**11,
                    'amount': 2*10**10,
                    'winner': True,
                    'expected_final_balance': 10**11 - 2*10**10,
                    'secret': 321,
                },
            ],
            10*10**9,
            2*10**9,
            int(time.time()) + 1000,
            10,
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
    revealing_duration,
    transfer_duration,
):
    lot_giver = make_lot_giver(
        prize,
        start_time,
        bidding_duration,
        revealing_duration,
        transfer_duration,
        root_address=root_contract.address,
    )
    auction_contract = make_auction_contract(
        root_contract=root_contract,
        lot_giver=lot_giver,
        start_time=start_time,
        bidding_duration=bidding_duration,
        revealing_duration=revealing_duration,
        transfer_duration=transfer_duration,
    )

    ts4.core.set_now(start_time + bidding_duration // 2)

    for bid in bids:
        make_bid(
            username=bid['username'],
            value=bid['value'],
            amount=bid['amount'],
            start_time=start_time,
            bidding_duration=bidding_duration,
            revealing_duration=revealing_duration,
            transfer_duration=transfer_duration,
            root_address=root_contract.address,
            auction_address=auction_contract.address,
            lot_reciever=dumb_reciever(),
            bid_back_reciever=dumb_reciever(),
            secret=bid['secret']
        )

    ts4.core.set_now(start_time + bidding_duration + revealing_duration // 2)

    for bid in bids:
        reveal_bid(
            auction_contract,
            bid['amount'],
            bid['username'],
        )

    ts4.core.set_now(start_time + bidding_duration + revealing_duration + 1)

    assert auction_contract.bid_reciever.balance <= epsilon
    auction_contract.call_method('end')
    ts4.dispatch_messages()
    assert lot_giver.balance < prize

    ts4.core.set_now(start_time + bidding_duration + revealing_duration + transfer_duration + 1)

    for bid in bids:
        take_bid_back(bid['username'])

    ts4.dispatch_messages()
    for bid in bids:
        assert abs(balance(bid['username']) -
                   bid['expected_final_balance']) <= epsilon

    for bid in bids:
        if bid['winner']:
            assert abs(auction_contract.bid_reciever.balance -
                       bid['amount']) <= epsilon
            assert abs(prize_balance(bid['username']) - prize) <= epsilon
        else:
            assert prize_balance(bid['username']) <= epsilon
