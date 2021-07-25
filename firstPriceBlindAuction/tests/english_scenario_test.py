import tonos_ts4.ts4 as ts4

import logging
import pytest
import time

from english_utils import (
    dumb_reciever,
    make_bid,
    make_root_contract,
    reveal_bid,
    take_bid_back,
    balance,
    prize_balance,
    make_auction_contract,
    make_lot_giver,
    make_root_contract,
)


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@pytest.mark.order(2)
@pytest.mark.parametrize(
    'bids, prize, epsilon, bidding_duration,'
    'transfer_duration, minimal_price, minimal_step',
    [
        (
            [
                {
                    'username': 'Petya',
                    'value': 115 * 10**9,
                    'amount': 110 * 10**9,
                    'winner': True,
                    'expected_final_balance': 3*10**9,
                    'reveal_ec': 0,
                },
                {
                    'username': 'Vasya',
                    'value': 113 * 10**9,
                    'amount': 100 * 10**9,
                    'winner': False,
                    'expected_final_balance': 112 * 10**9,
                    'reveal_ec': 0,
                },
                {
                    'username': 'Tima',
                    'value': 10**15 + 3 * 10**9,
                    'amount': 10**9,
                    'winner': False,
                    'expected_final_balance': 10**15 + 2 * 10**9,
                    # too small amount
                    'reveal_ec': 103,
                },
                {
                    'username': 'Chad',
                    'value': 115 * 10**9,
                    'amount': 110 * 10**9 + 1,
                    'winner': False,
                    # too small difference with current winner
                    'expected_final_balance': 114 * 10**9,
                    'reveal_ec': 0,
                },
            ],
            10 * 10**9,
            2 * 10**9,
            100,
            100,
            100 * 10**9,
            10**8,
        ),
    ]
)
def test_scenario(
    bids,
    prize,
    epsilon,
    bidding_duration,
    transfer_duration,
    minimal_price,
    minimal_step,
    pytestconfig
):
    ts4.reset_all()
    rootpath = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose=False)

    start_time = int(time.time()) + 1000
    end_time = start_time + bidding_duration + transfer_duration

    root_contract = make_root_contract()
    lot_giver = make_lot_giver(
        prize,
        end_time,
        root_address=root_contract.address,
    )
    auction_contract = make_auction_contract(
        root_contract=root_contract,
        lot_giver=lot_giver,
        start_time=start_time,
        bidding_duration=bidding_duration,
        transfer_duration=transfer_duration,
        minimal_price=minimal_price,
        minimal_step=minimal_step,
    )

    ts4.core.set_now(start_time)

    for bid in bids:
        make_bid(
            username=bid['username'],
            value=bid['value'],
            start_time=start_time,
            bidding_duration=bidding_duration,
            transfer_duration=transfer_duration,
            root_address=root_contract.address,
            auction_address=auction_contract.address,
            lot_reciever=dumb_reciever(),
            bid_back_reciever=dumb_reciever(),
        )

    ts4.core.set_now(start_time + 1)

    for bid in bids:
        reveal_bid(
            bid['amount'],
            bid['username'],
            bid['reveal_ec'],
        )

    ts4.core.set_now(start_time + bidding_duration + transfer_duration + 1)

    assert auction_contract.bid_reciever.balance < epsilon
    auction_contract.call_method('end')
    ts4.dispatch_messages()
    assert lot_giver.balance < epsilon

    ts4.core.set_now(end_time + 1)

    ts4.dispatch_messages()
    for bid in bids:
        assert balance(bid['username']) <= epsilon

    for bid in bids:
        take_bid_back(bid['username'])

    for bid in bids:
        delta = (abs(balance(bid['username']) -
                   bid['expected_final_balance']) // 10**9)
        e = epsilon // 10**9
        assert delta <= e

    for bid in bids:
        if bid['winner']:
            assert abs(auction_contract.bid_reciever.balance -
                       bid['amount']) <= epsilon
            assert abs(prize_balance(bid['username']) - prize) <= epsilon
        else:
            assert prize_balance(bid['username']) <= epsilon
