import os
import unittest

import tonos_ts4.ts4 as ts4

from errors import Errors
from phase import Phase
from test_wallet import TestWallet
from utils import random_address


class TestBase(unittest.TestCase):
    # todo 100 * ts4GRAM as default wallet value (maybe set in wallet)
    START_VALUE = 1 * ts4.GRAM  # todo set in methods, replace to 3
    STEP_VALUE = 1 * ts4.GRAM  # todo set in methods, replace to 0.5
    START_TIME = 10
    OPEN_DURATION = 30

    @classmethod
    def setUpClass(cls):
        path = os.getcwd() + '/../../build-artifacts/'
        ts4.init(path, verbose=True)

    def setUp(self):
        ts4.core.set_now(self.START_TIME - 1)
        self.contract = ts4.BaseContract('EnglishForwardAuctionTest', {
            'startValue': 1 * ts4.GRAM,
            'stepValue': 1 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        }, nickname='Auction', override_address=random_address())

    def test_start_time(self):
        open_time = self.contract.call_getter('getOpenTime')
        open_time_expected = {
            'startTime': self.START_TIME,
            'finishTime': self.START_TIME + self.OPEN_DURATION
        }
        self.assertEqual(open_time_expected, open_time)

    def test_phase(self):
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.WAIT, phase)

        self._update_with_time(self.START_TIME + 1)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.OPEN, phase)

        self._update_with_time(self.START_TIME + self.OPEN_DURATION + 1)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.CLOSE, phase)

    def test_bid_in_phases(self):
        wallet = TestWallet()

        self._make_bid(wallet, 1 * ts4.GRAM, expect_ec=Errors.WRONG_PHASE)
        self.assertEqual(0, self._get_bids_count())
        print(1)

        self._update_with_time(self.START_TIME + 1)
        self._make_bid(wallet, 1 * ts4.GRAM)
        self.assertEqual(1, self._get_bids_count())
        print(2)

        print('ph', self.contract.call_getter('getPhase'))
        self._update_with_time(self.START_TIME + self.OPEN_DURATION + 1)
        phase = self.contract.call_getter('getPhase')
        self.assertEqual(Phase.CLOSE, phase)
        self._make_bid(wallet, 1 * ts4.GRAM, expect_ec=Errors.WRONG_PHASE)
        self.assertEqual(1, self._get_bids_count())
        print(3)

        self.assertEqual(98 * ts4.GRAM, wallet.balance())
        print('BALANCE AUCTION: ', self.contract.balance())  # todo why not token spent for gas

    def _get_bids_count(self) -> int:
        return self.contract.call_getter('getBidsCount')

    def _update_with_time(self, time: int):
        ts4.core.set_now(time)
        self.contract.call_method('update')

    def test_rising_bids(self):
        wallet_1 = TestWallet()
        wallet_2 = TestWallet()
        wallet_3 = TestWallet()
        self._update_with_time(self.START_TIME + 1)
        self._make_bid(wallet_1, 1 * ts4.GRAM)
        self._make_bid(wallet_2, 3 * ts4.GRAM)
        self._make_bid(wallet_3, 12 * ts4.GRAM)
        self.assertEqual(3, self._get_bids_count())
        self.assertEqual(12 * ts4.GRAM, self.contract.call_getter('getWinnerValue'))

    def test_low_bids(self):
        wallet = TestWallet()

        self._update_with_time(self.START_TIME + 1)
        self._make_bid(wallet, int(0.1 * ts4.GRAM), expect_ec=199)

        self._make_bid(wallet, 1 * ts4.GRAM)  # good bid
        self._make_bid(wallet, int(1.5 * ts4.GRAM), expect_ec=199)

    def test_bid_return(self):
        self._update_with_time(self.START_TIME + 1)
        wallet_1 = TestWallet()
        wallet_2 = TestWallet()

        self._make_bid(wallet_1, 1 * ts4.GRAM)
        self.assertEqual(98 * ts4.GRAM, wallet_1.balance())

        self._make_bid(wallet_2, 2 * ts4.GRAM)
        self.assertEqual(97 * ts4.GRAM, wallet_2.balance())
        self.assertEqual(99 * ts4.GRAM, wallet_1.balance())  # todo in contact EXPLAIN

    def _make_bid(self, wallet: TestWallet, bid_value: int, expect_ec: int = 0):  # todo bid value as params
        value = bid_value + 1 * ts4.GRAM
        wallet.make_bid(self.contract.address(), value, bid_value, expect_ec=expect_ec)

    def _setup_start_time(self):  # todo set in class
        self._update_with_time(self.START_TIME + 1)

    def _setup_finish_time(self):  # todo set in class
        self._update_with_time(self.START_TIME + self.OPEN_DURATION + 1)


if __name__ == '__main__':
    print(ts4.G_TESTS_PATH)
    unittest.main()
