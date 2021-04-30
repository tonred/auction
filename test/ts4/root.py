import unittest

import tonos_ts4.ts4 as ts4

from config import BUILD_ARTIFACTS_PATH, VERBOSE
from utils.errors import Errors
from utils.utils import random_address


class RootAuctionTest(unittest.TestCase):
    AUCTION_NAMES = ('EnglishForward', 'EnglishReverse',
                     'DutchForward', 'DutchReverse',
                     'BlindForward', 'BlindReverse')

    def setUp(self):
        ts4.init(BUILD_ARTIFACTS_PATH, verbose=VERBOSE)
        ts4.core.set_now(0)
        self.auction_root = ts4.BaseContract('TestAuctionRoot', {
            'deployValue': 1 * ts4.GRAM,
            'defaultFeeValue': 1 * ts4.GRAM,
            'defaultDepositValue': 10 * ts4.GRAM,
        }, nickname='AuctionRoot', override_address=random_address())

        for auction_name in self.AUCTION_NAMES:
            code = ts4.load_code_cell(f'{auction_name}Auction')
            self.auction_root.call_method(f'setCode{auction_name}Auction', {
                f'code': code
            })
            ts4.dispatch_messages()
        code_blind_bid = ts4.load_code_cell(f'BlindBid')
        self.auction_root.call_method(f'setCodeBlindBid', {
            f'code': code_blind_bid
        })
        ts4.dispatch_messages()
        self.auction_root.call_method('finishInit', {})
        ts4.dispatch_messages()

    def test_inited(self):
        inited = self.auction_root.call_getter('isInited')
        self.assertEqual(True, inited)

    def test_call_before_init(self):
        self.auction_root = ts4.BaseContract('TestAuctionRoot', {
            'deployValue': 1 * ts4.GRAM,
            'defaultFeeValue': 1 * ts4.GRAM,
            'defaultDepositValue': 10 * ts4.GRAM,
        }, nickname='AuctionRoot', override_address=random_address())

        for auction_name in self.AUCTION_NAMES[:-1]:  # forget about 1 auction code
            code = ts4.load_code_cell(f'{auction_name}Auction')
            self.auction_root.call_method(f'setCode{auction_name}Auction', {
                f'code': code
            })
            ts4.dispatch_messages()
        self.auction_root.call_method('finishInit', {}, expect_ec=Errors.AUCTIONS_CODES_NOT_INITED)

    def test_after_init_call(self):
        code_blind_bid = ts4.load_code_cell(f'BlindBid')
        self.auction_root.call_method(f'setCodeBlindBid', {
            f'code': code_blind_bid
        }, expect_ec=Errors.IS_ALREADY_INITED)

    def test_double_init_call(self):
        self.auction_root.call_method('finishInit', {}, expect_ec=Errors.IS_ALREADY_INITED)

    def test_deploy_english_forward(self):
        self._deploy('EnglishForward', {
            'startValue': 1 * ts4.GRAM,
            'stepValue': 1 * ts4.GRAM,
            'startTime': 10,
            'openDuration': 20,
        })

    def test_deploy_english_reverse(self):
        self._deploy('EnglishReverse', {
            'startValue': 1 * ts4.GRAM,
            'stepValue': 1 * ts4.GRAM,
            'startTime': 10,
            'openDuration': 20,
        })

    def test_deploy_dutch_forward(self):
        self._deploy('DutchForward', {
            'startValue': 10 * ts4.GRAM,
            'finishValue': 1 * ts4.GRAM,
            'startTime': 10,
            'openDuration': 20,
        })

    def test_deploy_dutch_reverse(self):
        self._deploy('DutchReverse', {
            'startValue': 1 * ts4.GRAM,
            'finishValue': 10 * ts4.GRAM,
            'startTime': 10,
            'openDuration': 20,
        })

    def test_deploy_blind_forward(self):
        self._deploy('BlindForward', {
            'startTime': 10,
            'openDuration': 20,
            'confirmationDuration': 5,
        })

    def test_deploy_blind_reverse(self):
        self._deploy('BlindReverse', {
            'startTime': 10,
            'openDuration': 20,
            'confirmationDuration': 5,
        })

    def _deploy(self, auction_name: str, ctor_params: dict):
        address = self.auction_root.call_method(f'testDeploy{auction_name}Auction', ctor_params)
        ts4.dispatch_messages()
        self.assertIsNotNone(address)
