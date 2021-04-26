import unittest

import tonos_ts4.ts4 as ts4

from abstract.dutch import DutchAuctionTest
from test_wallet import TestWallet
from utils.errors import Errors
from utils.phase import Phase
from utils.utils import random_address


class DutchReverseAuctionTest(DutchAuctionTest):

    def setUp(self):
        self._setup_phase_time(Phase.WAIT)
        self.contract = ts4.BaseContract('DutchReverseAuction', {
            'startValue': 2 * ts4.GRAM,
            'finishValue': 10 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        }, nickname='Auction', override_address=random_address())

    def test_current_price(self):
        # 2 [0%] -> 4 [25%] -> 6 [50%] -> 8 [75%] -> 10 [100%]
        ts4.core.set_now(self.START_TIME)
        self.assertEqual(2 * ts4.GRAM, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.25 * self.OPEN_DURATION))
        self.assertEqual(4 * ts4.GRAM, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.5 * self.OPEN_DURATION))
        self.assertEqual(6 * ts4.GRAM, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.75 * self.OPEN_DURATION))
        self.assertEqual(8 * ts4.GRAM, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(self.START_TIME + self.OPEN_DURATION)
        self.assertEqual(10 * ts4.GRAM, self._current_price(), 'Wrong price calculation')

    def test_bid_in_open_phase(self):
        wallet = TestWallet()
        self._setup_phase_time(Phase.OPEN, update=True)
        self._buy(wallet, bid_value=5)
        self.assertEqual(Phase.CLOSE, self._phase(), 'Auction is not finished')
        self.assertEqual((100 - 1) * ts4.GRAM, wallet.balance(), 'Bid is not made')

    def test_high_bids_start(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()
        self._buy(wallet, bid_value=11, expect_ec=Errors.VALUE_MORE_THAN_CURRENT_PRICE)

    def test_high_bids_step(self):
        ts4.core.set_now(int(self.START_TIME + 0.5 * self.OPEN_DURATION))
        wallet = TestWallet()
        self._buy(wallet, bid_value=6.5, expect_ec=Errors.VALUE_MORE_THAN_CURRENT_PRICE)

    def _buy(self, wallet: TestWallet, bid_value: float, expect_ec: int = 0):
        destination = self.contract.address()
        bid_value = int(bid_value * ts4.GRAM)
        value = 1 * ts4.GRAM
        wallet.buy(destination, value, bid_value, expect_ec=expect_ec)


if __name__ == '__main__':
    unittest.main()
