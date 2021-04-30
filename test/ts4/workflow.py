import unittest

import tonos_ts4.ts4 as ts4

from config import BUILD_ARTIFACTS_PATH, VERBOSE
from test_wallet import TestWallet
from utils.utils import random_address


class WorkflowTest(unittest.TestCase):
    AUCTION_NAMES = ('EnglishForward', 'EnglishReverse',
                     'DutchForward', 'DutchReverse',
                     'BlindForward', 'BlindReverse')

    def setUp(self):
        ts4.init(BUILD_ARTIFACTS_PATH, verbose=VERBOSE)
        ts4.core.set_now(0)
        self.auction_root = ts4.BaseContract('TestAuctionRoot', {
            'deployValue': 2 * ts4.GRAM,
            'defaultFeeValue': 1 * ts4.GRAM,
            'defaultDepositValue': 10 * ts4.GRAM,
        }, nickname='AuctionRoot', override_address=random_address())

        for auction_name in self.AUCTION_NAMES:
            code = ts4.load_code_cell(f'{auction_name}Auction')
            self.auction_root.call_method(f'setCode{auction_name}Auction', {
                f'code{auction_name}Auction': code
            })
            ts4.dispatch_messages()
        code_blind_bid = ts4.load_code_cell(f'BlindBid')
        self.auction_root.call_method(f'setCodeBlindBid', {
            f'codeBlindBid': code_blind_bid
        })
        ts4.dispatch_messages()
        self.auction_root.call_method('finishInit', {})
        ts4.dispatch_messages()

    def test_workflow(self):
        user = ts4.BaseContract('TestUsage', {
            'auctionRoot': self.auction_root.address(),
        }, nickname='User', override_address=random_address())
        wallet = TestWallet()

        user.call_method('createAuction')
        ts4.dispatch_messages()
        auction_contact = user.call_getter('getAuctionContract')
        ts4.dispatch_messages()

        ts4.core.set_now(30)
        wallet.update(auction_contact, 1 * ts4.GRAM)
        wallet.make_bid(auction_contact, value=10 * ts4.GRAM, bid_value=9 * ts4.GRAM)

        ts4.core.set_now(100)
        wallet.update(auction_contact, 1 * ts4.GRAM)
        ts4.dispatch_messages()

        best_person = user.call_getter('getBestPerson')
        self.assertEqual(best_person, wallet.address())
        print(best_person)

    def deploy(self) -> ts4.Address:
        address = self.auction_root.call_method(f'testDeployEnglishForwardAuction', {
            'startValue': 1 * ts4.GRAM,
            'stepValue': 1 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        })
        ts4.dispatch_messages()
        return address

    @staticmethod
    def update(address: ts4.Address):
        wallet = TestWallet()
        wallet.update(address, 1 * ts4.GRAM)
