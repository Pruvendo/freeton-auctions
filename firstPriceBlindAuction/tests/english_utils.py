import logging

import tonos_ts4.ts4 as ts4

from dataclasses import dataclass


LOGGER = logging.getLogger(__name__)


@dataclass
class User:
    bid_giver: ts4.BaseContract
    bid_back_reciever: ts4.BaseContract
    lot_reciever: ts4.BaseContract
    keypair: (str, str)

users: dict[str, User] = {}


def make_root_contract():
    auction_code = ts4.load_code_cell('EnglishAuction')
    giver_code = ts4.load_code_cell('GiverNativeCurrency')
    bid_code = ts4.load_code_cell('BidNativeCurrencyEnglish')
    return ts4.BaseContract(
        'AuctionRootEnglish',
        dict(
            auctionCode_=auction_code,
            lotGiverCode_=giver_code,
            bidGiverCode_=bid_code,
        ),
        balance=10 ** 12,
        keypair=ts4.make_keypair(),
    )

def magic_arg(amount):
    ARG_CALCULATOR = ts4.BaseContract(
        '__NativeCurrencyEnglishBidRevealArgCalc',
        {},
        balance=10**10,
    )
    return ARG_CALCULATOR.call_method(
        'calc',
        dict(
            amount=amount,
        ),
    )

def magic_constructor_arg(
    # *,
    **kwargs,
):
    CONSTRUCTOR_ARG_CALCULATOR = ts4.BaseContract(
        '__NativeCurrencyEnglishBidConstructorArgCalc',
        {},
        balance=10**10,
    )
    auc_data, bid_data = CONSTRUCTOR_ARG_CALCULATOR.call_method(
        'calc',
        kwargs,
    )
    return {
        'auctionData': auc_data,
        'bidData': bid_data,
    }

def dumb_reciever():
    return ts4.BaseContract(
        '__DumbReciever',
        dict(),
        balance=10**9,
        keypair=ts4.make_keypair(),
    )


def make_bid(
    *,
    username,
    start_time,
    bidding_duration,
    transfer_duration,

    root_address,
    auction_address,
    lot_reciever,

    bid_back_reciever,
    value,
):
    keypair = ts4.make_keypair()
    bid = ts4.BaseContract(
        'BidNativeCurrencyEnglish',
        None,
        balance=value,
        keypair=keypair,
    )
    bid.call_method(
        'constructor',
        magic_constructor_arg(
            startTime_=start_time,
            biddingDuration_=bidding_duration,
            transferDuration_=transfer_duration,
            root_=root_address,
            auction_=auction_address,
            lotReciever_=lot_reciever.address,
        ),
        private_key=keypair[0],
    )
    user = User(
        bid_giver=bid,
        lot_reciever=lot_reciever,
        bid_back_reciever=bid_back_reciever,
        keypair=keypair,
    )
    users[username] = user


def reveal_bid(amount, username, expect_ec=0):
    ts4.dispatch_messages()
    user = users[username]
    bid = user.bid_giver
    bid.call_method(
        'reveal',
        dict(
            bidData=ts4.Cell(''),
            auctionData=magic_arg(amount),
        ),
        expect_ec=0,
        private_key=bid.private_key_
    )
    ts4.dispatch_one_message(expect_ec)
    ts4.dispatch_messages()


def take_bid_back(username, expect_ec=0):
    ts4.dispatch_messages()
    user = users[username]
    bid = user.bid_giver
    bid.call_method(
        'transferRemainsTo',
        dict(
            destination=user.bid_back_reciever.address
        ),
        private_key=user.keypair[0],
    )
    ts4.dispatch_one_message(expect_ec=expect_ec)


def balance(username):
    ts4.dispatch_messages()
    user = users[username]
    return user.bid_back_reciever.balance


def prize_balance(username):
    user = users[username]
    ts4.dispatch_messages()
    return user.lot_reciever.balance


def make_auction_contract(
    *,
    root_contract,
    lot_giver,
    start_time,
    bidding_duration,
    transfer_duration,
    minimal_price,
    minimal_step,
):
    reciever = dumb_reciever()
    ts4.dispatch_messages()
    auction_address = root_contract.call_method(
        'startAuctionScenario',
        dict(
            startTime=start_time,
            biddingDuration=bidding_duration,
            transferDuration=transfer_duration,

            minimalPrice=minimal_price,
            minimalStep=minimal_step,

            lotGiver=lot_giver.address,
            bidReciever=reciever.address,
        ),
        private_key=root_contract.private_key_,
    )

    ts4.Address.ensure_address(auction_address)
    ts4.dispatch_messages()
    res = ts4.BaseContract(
        'FirstPriceAuction',
        ctor_params=None,
        address=auction_address,
    )
    ts4.dispatch_messages()
    res.bid_reciever = reciever
    res.lot_giver = lot_giver
    return res


def make_lot_giver(
        prize,
        end_time,
        root_address,
    ) -> ts4.BaseContract:

    return ts4.BaseContract(
        'GiverNativeCurrency',
        dict(
            root_=root_address,
            endTime_=end_time,
        ),
        balance=prize,
        keypair=ts4.make_keypair()
    )
