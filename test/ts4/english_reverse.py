import unittest

import tonos_ts4.ts4 as ts4

from abstract.english import EnglishAuctionTest
from test_wallet import TestWallet
from utils.errors import Errors
from utils.phase import Phase
from utils.utils import random_address


class EnglishReverseAuctionTest(EnglishAuctionTest):

    def setUp(self):
        self._setup_phase_time(Phase.WAIT)
        self.contract = ts4.BaseContract('EnglishReverseAuction', {
            'startValue': 10 * ts4.GRAM,
            'stepValue': int(0.5 * ts4.GRAM),
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        }, nickname='Auction', override_address=random_address())

    def test_bid_in_open_phase(self):
        wallet = TestWallet()
        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(wallet, bid_value=3)
        self._check_bids_count(1)
        self.assertEqual((100 - 1) * ts4.GRAM, wallet.balance(), 'Bid is not made')

    def test_decreasing_bids(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet_1 = TestWallet()
        wallet_2 = TestWallet()
        wallet_3 = TestWallet()

        self._make_bid(wallet_1, bid_value=10)
        self._make_bid(wallet_2, bid_value=5)
        self._make_bid(wallet_3, bid_value=3)
        self._check_bids_count(3)
        self.assertEqual(3 * ts4.GRAM, self.contract.call_getter('getWinnerValue'), 'Bid is not made')

    def test_high_bids_start(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()
        self._make_bid(wallet, bid_value=100, expect_ec=Errors.VALUE_MORE_THAN_START_VALUE)
        self._check_bids_count(0)

    def test_low_bids_step(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()
        self._make_bid(wallet, bid_value=10)  # good bid
        self._make_bid(wallet, bid_value=9.9, expect_ec=Errors.VALUE_MORE_THAN_STEP_FROM_LOWEST_VALUE)
        self._check_bids_count(1)

    def _make_bid(self, wallet: TestWallet, bid_value: float, expect_ec: int = 0):
        destination = self.contract.address()
        bid_value = int(bid_value * ts4.GRAM)
        value = 1 * ts4.GRAM
        wallet.make_bid(destination, value, bid_value, expect_ec=expect_ec)


if __name__ == '__main__':
    unittest.main()
