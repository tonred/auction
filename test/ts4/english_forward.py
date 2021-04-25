import unittest

import tonos_ts4.ts4 as ts4

from abstract.english import EnglishAuctionTest
from test_wallet import TestWallet
from utils.errors import Errors
from utils.phase import Phase
from utils.utils import random_address


class EnglishForwardAuctionTest(EnglishAuctionTest):

    def setUp(self):
        self._setup_phase_time(Phase.WAIT)
        self.contract = ts4.BaseContract('EnglishForwardAuctionTest', {
            'startValue': 3 * ts4.GRAM,
            'stepValue': int(0.5 * ts4.GRAM),
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        }, nickname='Auction', override_address=random_address())

    def test_open_time(self):
        open_time = self.contract.call_getter('getOpenTime')
        open_time_expected = {
            'startTime': self.START_TIME,
            'finishTime': self.START_TIME + self.OPEN_DURATION
        }
        self.assertEqual(open_time_expected, open_time)

    def test_phases(self):
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.WAIT, phase)

        self._setup_phase_time(Phase.OPEN, update=True)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.OPEN, phase)

        self._setup_phase_time(Phase.CLOSE, update=True)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.CLOSE, phase)

    def test_bid_in_phases(self):
        wallet = TestWallet()

        self._make_bid(wallet, bid_value=3, expect_ec=Errors.WRONG_PHASE)
        self._check_bids_count(0)

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(wallet, bid_value=3)
        self._check_bids_count(1)

        self._setup_phase_time(Phase.CLOSE, update=True)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.CLOSE, phase)
        self._make_bid(wallet, bid_value=3, expect_ec=Errors.WRONG_PHASE)
        self._check_bids_count(1)

        self.assertEqual((100 - (3 + 1)) * ts4.GRAM, wallet.balance())
        print('BALANCE AUCTION: ', self.contract.balance())  # todo why not token spent for gas

    def test_rising_bids(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet_1 = TestWallet()
        wallet_2 = TestWallet()
        wallet_3 = TestWallet()

        self._make_bid(wallet_1, bid_value=3)
        self._make_bid(wallet_2, bid_value=5)
        self._make_bid(wallet_3, bid_value=12)
        self._check_bids_count(3)
        self.assertEqual(12 * ts4.GRAM, self.contract.call_getter('getWinnerValue'))

    def test_low_bids(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()

        self._make_bid(wallet, bid_value=1, expect_ec=199)

        self._make_bid(wallet, bid_value=3)  # good bid
        self._make_bid(wallet, bid_value=3.1, expect_ec=199)

    def test_bid_return(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet_1 = TestWallet()
        wallet_2 = TestWallet()

        self._make_bid(wallet_1, bid_value=3)
        self.assertEqual((100 - (3 + 1)) * ts4.GRAM, wallet_1.balance())

        self._make_bid(wallet_2, bid_value=4)
        self.assertEqual((100 - (4 + 1)) * ts4.GRAM, wallet_2.balance())
        self.assertEqual((100 - 1) * ts4.GRAM, wallet_1.balance())  # todo in contact EXPLAIN

    def _make_bid(self, wallet: TestWallet, bid_value: float, expect_ec: int = 0):
        destination = self.contract.address()
        bid_value = int(bid_value * ts4.GRAM)
        value = bid_value + 1 * ts4.GRAM
        wallet.make_bid(destination, value, bid_value, expect_ec=expect_ec)


if __name__ == '__main__':
    unittest.main()
