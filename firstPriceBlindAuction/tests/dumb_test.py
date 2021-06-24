# pyright: reportMissingImports=false
import tonos_ts4.ts4 as ts4

import pathlib
import time
import logging

from pytest import fixture


eq = ts4.eq

LOGGER = logging.getLogger(__name__)


@fixture
def contract(pytestconfig):
    rootpath: pathlib.Path = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose = False)
    auction_code = ts4.load_code_cell('Auction.tvc')
    giver_code = ts4.load_code_cell('Giver.tvc')
    bid_code = ts4.load_code_cell('Bid.tvc')
    return ts4.BaseContract(
        'AuctionRoot',
        dict(
            auctionCodeArg=auction_code,
            giverCodeArg=giver_code,
            bidCodeArg=bid_code,
        ),
        # pubkey='0xaa1787d058eafdf4453274b063e4ddfb05492ddc1b01e91d06681466f35475ed',
        balance=100000000000,
        nickname = 'Root'
    )

@fixture
def auction_contract(contract):
    auction_address = contract.call_method('startAuctionScenario', dict(
        prize=100500,
        startTime=int(time.time()) + 10,
        biddingDuration=1,
        revealingDuration=1,
        publicKey='0x00'
    ))
    # LOGGER.debug(auctions[i])

    ts4.Address.ensure_address(auction_address)
    ts4.register_nickname(auction_address, 'Auction')
    ts4.dispatch_messages()
    return ts4.BaseContract(
        'Auction',
        ctor_params=None,
        address=auction_address,
        nickname='AuctionInstance'
    )

@fixture
def bid(auction_contract):
    pass


def test_hello(contract):
    answer = contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)

def test_deploy_auction(auction_contract):
    answer = auction_contract.call_getter('renderHelloWorld')
    assert eq('Hello World', answer)
